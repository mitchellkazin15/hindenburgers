class_name GameGoalBody3D
extends StaticBody3D

@export var scoring_area : Area3D
@export_file var scoring_item_path : String
@export var leaderboard_label : Label3D
@export var leaderboard_size : int = 3
@export var score_particles : GPUParticles3D
@export var prize_cloaca : Cloaca
## List of Lists whose first item is min distance the scorring item needs to travel to get the specific prize
## NOTE: list is expected to be sorted in ascending distance
@export var prize_list = [
	[ 10.0, preload("res://items/money/penny.tscn") ],
	[ 20.0, preload("res://items/money/nickel.tscn") ],
	[ 50.0, preload("res://items/money/dime.tscn") ],
	[ 100.0, preload("res://items/money/dollar.tscn") ]
]

## Example tuple to be added to leaderboard: [ "N/A", 0.0 ]
var leaderboard = []


func _ready() -> void:
	scoring_area.body_entered.connect(_on_body_entered)
	display_leaderboard()


func _on_body_entered(body):
	if not MultiplayerManager.safe_is_multiplayer_authority(self) or not body is HoldableItem:
		return
	var item : HoldableItem = body
	if not item.prev_item_holder or not item.prev_release_position:
		return
	item.apply_central_impulse(item.mass * -item.linear_velocity)
	print(scoring_item_path)
	print(ResourceUID.uid_to_path(scoring_item_path))
	print(item.get_scene_file_path())
	if not ResourceUID.uid_to_path(scoring_item_path) == item.get_scene_file_path():
		return
	var distance_thrown = (self.global_position - item.prev_release_position).length()
	generate_prize(distance_thrown)
	update_leaderboard.rpc(distance_thrown, item.prev_item_holder.display_name)
	item.prev_item_holder = null


func generate_prize(distance_thrown : float):
	print(distance_thrown)
	var curr_prize : PackedScene
	var dict = {}
	for prize_tuple in prize_list:
		if distance_thrown > prize_tuple[0]:
			curr_prize = prize_tuple[1]
	if curr_prize:
		prize_cloaca.poop_scene = curr_prize
		prize_cloaca.poop()


@rpc("any_peer", "call_local", "reliable")
func update_leaderboard(distance_thrown : float, thrower : String):
	score_particles.restart()
	if leaderboard.size() < leaderboard_size:
		leaderboard.append([thrower, distance_thrown])
	else:
		for leader in leaderboard:
			if distance_thrown > leader[1]:
				leaderboard.remove_at(-1)
				leaderboard.append([thrower, distance_thrown])
	leaderboard.sort_custom(func(a, b): return a[1] > b[1])
	display_leaderboard.rpc()


@rpc("any_peer", "call_local", "reliable")
func display_leaderboard():
	var new_text = "Leaderboard:\n"
	for leader in leaderboard:
		new_text += "%s: %.2fm\n" % leader
	leaderboard_label.text = new_text

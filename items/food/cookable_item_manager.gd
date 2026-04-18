class_name CookableItemManager
extends Node3D

@onready var top_raycast = $TopRayCast3D
@onready var bottom_raycast = $BottomRayCast3D

@export var cookable_item : EdibleItem
@export var top_mesh : MeshInstance3D
@export var bottom_mesh : MeshInstance3D
@export var per_side_cook_time = 30.0
@export var per_side_burn_time = 60.0
@export var cooked_item_scene : PackedScene
@export var cooked_color : Color
@export var burnt_color : Color

var top_side_cook_timer : Stopwatch
var bottom_side_cook_timer : Stopwatch
var burnt = false


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	top_side_cook_timer = StopwatchManager.create_stopwatch()
	bottom_side_cook_timer = StopwatchManager.create_stopwatch()


func _physics_process(delta: float) -> void:
	if burnt:
		return
	var top_cooked = top_side_cook_timer.time_elapsed_sec > per_side_cook_time 
	var bottom_cooked = bottom_side_cook_timer.time_elapsed_sec > per_side_cook_time
	if top_cooked or bottom_cooked:
		display_cooked_sides.rpc(top_cooked, bottom_cooked)
	var top_collider = top_raycast.get_collider()
	var bottom_collider = bottom_raycast.get_collider()
	if top_cooked and bottom_cooked and top_collider is Bun and bottom_collider is Bun:
		var top_bun = top_collider
		var bottom_bun = bottom_collider
		spawn_cooked_item(top_bun, bottom_bun)
	if top_collider is CookingBody:
		top_side_cook_timer.start()
	else:
		top_side_cook_timer.stop()
	if bottom_collider is CookingBody:
		bottom_side_cook_timer.start()
	else:
		bottom_side_cook_timer.stop()
	burnt = top_side_cook_timer.time_elapsed_sec > per_side_burn_time or bottom_side_cook_timer.time_elapsed_sec > per_side_burn_time
	if burnt:
		top_side_cook_timer.stop()
		bottom_side_cook_timer.stop()
		display_burnt.rpc()


func spawn_cooked_item(top_bun, bottom_bun):
	var cooked_item = MultiplayerManager.add_node_to_spawner(cooked_item_scene.resource_path, cookable_item.global_position)
	MultiplayerManager.broadcast_queue_free(cookable_item)
	MultiplayerManager.broadcast_queue_free(top_bun)
	MultiplayerManager.broadcast_queue_free(bottom_bun)


@rpc("any_peer", "call_local", "reliable")
func display_cooked_sides(top_cooked, bottom_cooked):
	var material : StandardMaterial3D
	if top_cooked:
		material = top_mesh.mesh.material
		material.albedo_color = cooked_color
	if bottom_cooked:
		material = bottom_mesh.mesh.material
		material.albedo_color = cooked_color


@rpc("any_peer", "call_local", "reliable")
func display_burnt():
	var top_material : StandardMaterial3D = top_mesh.mesh.material
	top_material.albedo_color = burnt_color
	var bottom_material : StandardMaterial3D = bottom_mesh.mesh.material
	bottom_material.albedo_color = burnt_color

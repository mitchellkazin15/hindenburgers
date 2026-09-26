class_name ReviveArea3D
extends Area3D

@export var revive_pos : Node3D
@export var revive_time = 2.0
@export var revive_particles : GPUParticles3D

var revive_character : Character = null
var revive_reset_timer : SceneTreeTimer
var revive_reset_time = 0.5


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	revive_reset_timer = get_tree().create_timer(0.0)


func _physics_process(delta: float) -> void:
	if revive_character or not MultiplayerManager.safe_is_multiplayer_authority(self) or revive_reset_timer.time_left != 0.0:
		return
	for body in get_overlapping_bodies():
		_on_body_entered(body)


func _on_body_entered(body):
	if (revive_character != null or
		not body is HoldableItem or 
		body == get_parent() or
		not body is Character or
		body.being_held or 
		not body.is_dead
	):
		return
	revive_character = body
	revive_character.set_being_held(null)
	var tween = get_tree().create_tween()
	tween.tween_property(body, "global_position", revive_pos.global_position, revive_time)
	tween.tween_property(body, "global_rotation", revive_pos.global_rotation, revive_time)
	tween.finished.connect(_on_revive_finished)


func _on_revive_finished():
	if not revive_character:
		return
	revive_character.freeze = false
	revive_reset_timer = get_tree().create_timer(revive_reset_time)
	revive_character.revive()
	revive_character = null
	start_particles.rpc()


@rpc("any_peer", "call_local", "reliable")
func start_particles():
	revive_particles.restart()

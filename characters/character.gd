class_name Character
extends CharacterBody3D

signal locked_interaction_ended

@export var camera : Camera3D
@export var controllable = true
@export var synchronizer : MultiplayerSynchronizer

var move_input : Vector2 = Vector2.ZERO
var is_jumping = false
var locked_interaction = false

var speed = 15.0
var jump_speed = 20.0
var acceleration = 25.0
var gravity = 50
var terminal_speed = 1000.0


func _ready() -> void:
	print("loading character for peer: ", multiplayer.get_unique_id())
	if is_multiplayer_authority():
		camera.current = true


@rpc("any_peer", "call_local", "reliable")
func set_initial_values(pos, multiplayer_authority):
	position = pos
	set_multiplayer_authority(multiplayer_authority, true)
	set_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	synchronizer.set_multiplayer_authority(multiplayer_authority)
	camera.current = is_multiplayer_authority()


func set_locked_interacting():
	locked_interaction = true
	controllable = false
	camera.current = false


func end_locked_interaction():
	locked_interaction = false
	controllable = true
	camera.current = true
	locked_interaction_ended.emit()


func _physics_process(delta: float) -> void:
	process_movement(delta)


func process_movement(delta: float) -> void:
	if not controllable:
		return
	var forward = camera.global_basis.z
	var right = camera.global_basis.x
	var move_direction = forward * move_input.y + right * move_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	var ground_plane_vel = Vector2(velocity.x, velocity.z)
	ground_plane_vel = ground_plane_vel.move_toward(speed * Vector2(move_direction.x, move_direction.z), acceleration * delta)
	velocity.x = ground_plane_vel.x
	velocity.z = ground_plane_vel.y
	velocity.y = min(terminal_speed, velocity.y - gravity * delta)
	if is_on_floor() and is_jumping:
		velocity.y = jump_speed
	move_and_slide()

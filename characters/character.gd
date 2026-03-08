class_name Character
extends RigidBody3D

signal locked_interaction_ended

@export var camera : Camera3D
@export var controllable = true
@export var synchronizer : MultiplayerSynchronizer
@export var initial_multiplayer_authority : int
@export var initial_position : Vector3
@export var floor_ray_cast : RayCast3D
@export var stats : CharacterStatManager

var move_input : Vector2 = Vector2.ZERO
var is_jumping = false
var is_sprinting = false
var locked_interaction = false

var speed = 20.0
var jump_speed = 20.0
var jump_lockout_time = 0.1

var _jump_lock_timer : SceneTreeTimer
var _can_jump = true


func _enter_tree() -> void:
	set_initial_values(initial_position, initial_multiplayer_authority)


@rpc("any_peer", "call_local", "reliable")
func set_initial_values(pos, multiplayer_authority):
	position = pos
	set_multiplayer_authority(multiplayer_authority, true)
	set_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	synchronizer.set_multiplayer_authority(multiplayer_authority, true)
	camera.current = is_multiplayer_authority()
	if not is_multiplayer_authority():
		print("received broadcast")


func broadcast_initial_values() -> void:
	print("broadcasting ", self.name)
	set_initial_values.rpc(initial_position, initial_multiplayer_authority)


func reset():
	if locked_interaction:
		end_locked_interaction()
	freeze = true
	position = initial_position
	linear_velocity = Vector3.ZERO
	freeze = false


func set_locked_interacting():
	locked_interaction = true
	controllable = false
	camera.current = false
	freeze = true


func end_locked_interaction():
	locked_interaction = false
	controllable = true
	camera.current = true
	freeze = false
	locked_interaction_ended.emit()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not controllable:
		return
	var forward = camera.global_basis.z
	var right = camera.global_basis.x
	var move_direction = forward * move_input.y + right * move_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	var collider = floor_ray_cast.get_collider()
	var relative_linear_vel = state.linear_velocity
	if collider and collider is RigidBody3D:
		relative_linear_vel -= collider.linear_velocity
	var speed = stats.get_current_speed()
	if is_sprinting:
		speed *= stats.get_current_sprint_multiplier()
	var target_ground_plane_vel = (speed * move_direction) - relative_linear_vel
	target_ground_plane_vel.y = 0.0
	state.apply_central_impulse(target_ground_plane_vel)
	if is_jumping and _can_jump and floor_ray_cast.is_colliding():
		state.apply_central_impulse(stats.get_current_jump_impulse() * Vector3.UP)
		_can_jump = false
		_jump_lock_timer = get_tree().create_timer(jump_lockout_time)
		_jump_lock_timer.timeout.connect(_on_jump_lock_timeout)

func _on_jump_lock_timeout():
	_can_jump = true

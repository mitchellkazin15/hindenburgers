class_name Character
extends RigidBody3D

signal locked_interaction_ended

@export var camera : Camera3D
@export var controllable = true
@export var input_controller : CharacterPlayerInputController
@export var synchronizer : MultiplayerSynchronizer
@export var initial_multiplayer_authority : int
@export var initial_position : Vector3
@export var floor_ray_cast : RayCast3D
@export var stats : CharacterStatManager
@export var hand : RemoteTransform3D

const host_authority = 1
var move_direction : Vector3
var is_jumping = false
var is_sprinting = false
var locked_interaction = false
var held_item : HoldableItem = null
var reset_input = false

var speed = 20.0
var jump_speed = 20.0
var jump_lockout_time = 0.1

var _jump_lock_timer : SceneTreeTimer
var _can_jump = true


func _enter_tree() -> void:
	position = initial_position
	set_multiplayer_authority(host_authority, true)
	set_process(multiplayer.is_server())
	set_physics_process(multiplayer.is_server())
	set_process_input(multiplayer.is_server())


@rpc("any_peer", "call_local", "reliable")
func set_initial_values(pos, multiplayer_authority):
	position = pos
	set_multiplayer_authority(host_authority, true)
	set_process(multiplayer.is_server())
	set_physics_process(multiplayer.is_server())
	set_process_input(multiplayer.is_server())
	camera.set_multiplayer_authority(multiplayer_authority)
	camera.set_process(camera.is_multiplayer_authority())
	camera.set_process_input(camera.is_multiplayer_authority())
	camera.current = camera.is_multiplayer_authority()
	input_controller.set_multiplayer_authority(multiplayer_authority)
	input_controller.set_process(input_controller.is_multiplayer_authority())
	input_controller.set_process_input(input_controller.is_multiplayer_authority())
	synchronizer.set_multiplayer_authority(host_authority)


func reset():
	if locked_interaction:
		print("sending reset result to: ", camera.get_multiplayer_authority())
		end_locked_interaction.rpc_id(camera.get_multiplayer_authority())
		end_locked_interaction()
	freeze = true
	position = initial_position
	linear_velocity = Vector3.ZERO
	freeze = false
	reset_input = false


func set_locked_interacting():
	locked_interaction = true
	controllable = false
	camera.current = false
	freeze = true


@rpc("any_peer", "call_local", "reliable")
func end_locked_interaction():
	locked_interaction = false
	controllable = true
	camera.current = camera.is_multiplayer_authority()
	freeze = false
	locked_interaction_ended.emit()


func grab_item(item : HoldableItem):
	if held_item != null:
		return false
	hand.remote_path = item.get_path()
	held_item = item
	return true


func throw_item():
	if held_item == null:
		return
	hand.remote_path = NodePath("")
	held_item.release.rpc()
	held_item.apply_central_impulse(2.0 * $RotationPivot.global_basis.z)
	held_item = null


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not is_multiplayer_authority():
		return
	if not controllable:
		return
	if reset_input:
		reset()
		return
	var collider = floor_ray_cast.get_collider()
	var relative_linear_vel = state.linear_velocity
	if collider and collider is RigidBody3D:
		relative_linear_vel -= collider.linear_velocity
	var speed = stats.get_current_speed()
	if move_direction != Vector3.ZERO:
		$RotationPivot.rotation.y = lerp_angle($RotationPivot.rotation.y, global_basis.z.signed_angle_to(move_direction, Vector3.UP), min(10.0 * state.step, 1.0))
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

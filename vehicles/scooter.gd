class_name Scooter
extends Vehicle

@export var raycast : RayCast3D
@export var speed = 35.0
@export var air_torque = 10.0
@export var left_raycast : RayCast3D
@export var right_raycast : RayCast3D


var move_input : Vector2 = Vector2.ZERO
var move_direction : Vector3 = Vector3.ZERO
var is_rising = false
var is_boosting = false

var _jump_lock_timer : SceneTreeTimer
var jump_lockout_time = 1.0

func _ready() -> void:
	super._ready()
	_jump_lock_timer = get_tree().create_timer(0.0)


func set_driver(driving_character: Character) -> bool:
	lock_rotation = false
	return super.set_driver(driving_character)


func _on_end_locked_interaction() -> void:
	super._on_end_locked_interaction()
	lock_rotation = true


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not being_driven or not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	var forward = global_basis.z
	var scooter_right = global_basis.x
	var is_on_floor = raycast.is_colliding() and _jump_lock_timer.time_left == 0.0
	if not is_on_floor:
		if left_raycast.is_colliding():
			state.apply_torque_impulse(25.0 * global_basis.z)
			state.apply_impulse(10.0 * global_basis.x)
		elif right_raycast.is_colliding():
			state.apply_torque_impulse(-25.0 * global_basis.z)
			state.apply_impulse(-10.0 * global_basis.x)
		else:
			state.apply_torque(-air_torque * move_input.y * global_basis.x)
			state.apply_torque(air_torque * move_input.x * global_basis.z)
			return
	var target_up = raycast.get_collision_normal()# scooter still flattens onto a slope).
	var desired_forward
	if move_direction.length_squared() > 0.0001:
		desired_forward = move_direction
	else:
		desired_forward = global_basis.z

	desired_forward = desired_forward - target_up * desired_forward.dot(target_up)
	desired_forward = desired_forward.normalized()
	var sign = -1.0 if move_input.y == 0.0 else sign(move_input.y)
	var target_basis = Basis.looking_at(sign * desired_forward, target_up)
	var t = 1.0 - exp(-3.0 * state.step)
	global_basis = global_basis.slerp(target_basis, t)

	var forward_vel = state.linear_velocity.project(forward)
	var perp_vel = state.linear_velocity.project(scooter_right)
	var kill_perp_vel_impulse = -perp_vel * mass
	state.apply_central_impulse(kill_perp_vel_impulse)
	var modified_speed = speed
	if is_boosting:
		modified_speed *= 2.0
	if move_direction.length() > 0.0:
		state.apply_central_force(modified_speed * forward * sign(move_direction.dot(forward)))
	if is_rising and _jump_lock_timer.time_left == 0.0:
		state.apply_central_impulse(100.0 * global_basis.y)
		_jump_lock_timer = get_tree().create_timer(jump_lockout_time)
	state.angular_velocity = Vector3.ZERO

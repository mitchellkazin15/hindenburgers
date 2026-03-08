class_name Blimp
extends Vehicle

@export var stats : BlimpStatManager


var move_input : Vector2 = Vector2.ZERO
var is_rising = false
var is_boosting = false


func _ready() -> void:
	camera.current = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not being_driven:
		return
	var forward = camera.global_basis.z
	var right = camera.global_basis.x
	var move_direction = forward * move_input.y
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	var ground_plane_move = Vector2(move_direction.x, move_direction.z)
	var blimp_forward = -global_basis.z
	var accel_scalar = abs(move_direction.dot(blimp_forward)) * (stats.get_current_boost_acceleration_multiplier() if is_boosting else 1.0)
	state.apply_central_force(mass * accel_scalar * stats.get_current_acceleration() * move_direction)
	var rotation_direction = (right * move_input.x).normalized()
	state.apply_torque(-1 * mass * sign(move_input.x) * stats.get_current_rotational_torque_scalar() * Vector3(0, 1, 0))
	var righting_axis = global_basis.y.normalized().cross(Vector3.UP);
	state.apply_torque(mass * stats.get_current_righting_torque_scalar() * righting_axis)
	if is_rising:
		state.apply_central_force(mass * stats.get_current_rising_acceleration() * Vector3.UP)
	if state.linear_velocity.length() > stats.get_current_max_speed():
		state.linear_velocity = stats.get_current_max_speed() * state.linear_velocity.normalized()

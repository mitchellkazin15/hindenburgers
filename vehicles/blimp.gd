class_name Blimp
extends Vehicle

@export var stats : BlimpStatManager


var move_input : Vector2 = Vector2.ZERO
var move_direction : Vector3 = Vector3.ZERO
var is_rising = false
var is_boosting = false


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not being_driven or not is_multiplayer_authority():
		return
	var ground_plane_move = Vector2(move_direction.x, move_direction.z)
	var blimp_forward = -global_basis.z
	var accel_scalar = abs(move_direction.dot(blimp_forward)) * (stats.get_current_boost_acceleration_multiplier() if is_boosting else 1.0)
	var drive_dir = move_direction.rotated(Vector3.UP, driver.rand_angle)
	state.apply_central_force(mass * accel_scalar * stats.get_current_acceleration() * drive_dir)
	var right = camera.global_basis.x
	var rotation_direction = (right * move_input.x).normalized().rotated(Vector3.UP, driver.rand_angle)
	state.apply_torque(-1 * mass * sign(move_input.x) * stats.get_current_rotational_torque_scalar() * Vector3(0, 1, 0))
	var righting_axis = global_basis.y.normalized().cross(Vector3.UP);
	state.apply_torque(mass * stats.get_current_righting_torque_scalar() * righting_axis)
	if is_rising:
		var rising_force = mass * stats.get_current_rising_acceleration() * Vector3.UP
		if global_position.y > stats.get_current_max_altitude():
			var slowdown_window = stats.get_current_max_altitude() * 0.1
			var diff = global_position.y - stats.get_current_max_altitude()
			var ratio = min(diff / slowdown_window, 1.0)
			rising_force *= cos(ratio * PI / 2.0)
		state.apply_central_force(rising_force)

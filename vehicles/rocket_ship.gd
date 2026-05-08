class_name RocketShip
extends Vehicle

@export var stats : BlimpStatManager
@export var lift_button : ButtonArea3D
@export var forward_button : ButtonArea3D
@export var backward_button : ButtonArea3D
@export var right_button : ButtonArea3D
@export var left_button : ButtonArea3D
@export var rotating_torque = 10.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	if global_position.y > stats.get_current_max_altitude():
		lift_button.is_pressed = false
	if lift_button.is_pressed:
		var rising_force = mass * stats.get_current_rising_acceleration() * global_basis.y
		state.apply_central_force(rising_force)
	if forward_button.is_pressed:
		state.apply_torque(rotating_torque * mass * global_basis.x)
	if backward_button.is_pressed:
		state.apply_torque(-rotating_torque * mass * global_basis.x)
	if right_button.is_pressed:
		state.apply_torque(rotating_torque * mass * global_basis.z)
	if left_button.is_pressed:
		state.apply_torque(-rotating_torque * mass * global_basis.z)
	var righting_axis = global_basis.y.normalized().cross(Vector3.UP);
	state.apply_torque(stats.get_current_righting_torque_scalar() * righting_axis)

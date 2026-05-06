class_name HotAirBalloon
extends Vehicle

@export var stats : BlimpStatManager
@export var button : ButtonArea3D


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	if global_position.y > stats.get_current_max_altitude():
		button.is_pressed = false
	if not button.is_pressed:
		return
	var rising_force = mass * stats.get_current_rising_acceleration() * global_basis.y
	state.apply_central_force(rising_force)
	var righting_axis = global_basis.y.normalized().cross(Vector3.UP);
	state.apply_torque(stats.get_current_righting_torque_scalar() * righting_axis)

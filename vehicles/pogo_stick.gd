class_name PogoStick
extends Vehicle


var move_input : Vector2 = Vector2.ZERO
var move_direction : Vector3 = Vector3.ZERO
var is_rising = false
var is_boosting = false

var _jump_lock_timer : SceneTreeTimer

func _ready() -> void:
	super._ready()
	_jump_lock_timer = get_tree().create_timer(0.0)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	super._integrate_forces(state)
	if not being_driven or not is_multiplayer_authority():
		return
	var ground_plane_move = Vector3(move_direction.x, 0.0, move_direction.z).rotated(Vector3.UP, driver.rand_angle)
	var pogo_forward = -global_basis.z
	var is_on_floor = $RayCast3D.is_colliding()
	if is_on_floor:
		var can_jump = _jump_lock_timer.time_left == 0.0
		var will_jump = can_jump and is_rising
		var jump_power = 250.0 if will_jump else 50.0
		if will_jump:
			_jump_lock_timer = get_tree().create_timer(0.1)
		if move_direction.length() > 0.0:
			apply_central_impulse(20.0 * ground_plane_move + jump_power * Vector3.UP)
		else:
			apply_central_impulse(jump_power * Vector3.UP)
	else:
		apply_central_force(20.0 * move_direction)
	if move_direction != Vector3.ZERO:
		$RotationPivot.rotation.y = lerp_angle($RotationPivot.rotation.y, global_basis.z.signed_angle_to(move_direction, Vector3.UP), min(10.0 * state.step, 1.0))

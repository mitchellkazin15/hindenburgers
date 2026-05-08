class_name Scooter
extends Vehicle

@export var raycast : RayCast3D


var move_input : Vector2 = Vector2.ZERO
var move_direction : Vector3 = Vector3.ZERO
var is_rising = false
var is_boosting = false

var _jump_lock_timer : SceneTreeTimer
var jump_lockout_time = 0.5

func _ready() -> void:
	super._ready()
	_jump_lock_timer = get_tree().create_timer(0.0)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not being_driven or not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	var scooter_forward = $RotationPivot.global_basis.z
	var scooter_right = $RotationPivot.global_basis.x
	var is_on_floor = raycast.is_colliding()
	if is_on_floor:
		rotation = lerp(rotation, raycast.get_collision_normal(), 0.1)
		var forward_vel = state.linear_velocity.project(scooter_forward)
		var perp_vel = state.linear_velocity.project(scooter_right)
		var kill_perp_vel_impulse = -perp_vel * mass
		apply_central_impulse(kill_perp_vel_impulse)
		if move_direction.length() > 0.0:
			apply_central_force(35.0 * scooter_forward * sign(move_direction.dot(scooter_forward)))
		if is_rising and _jump_lock_timer.time_left == 0.0:
			apply_central_impulse((100.0 - (linear_velocity.y * mass)) * Vector3.UP)
			_jump_lock_timer = get_tree().create_timer(jump_lockout_time)
	else:
		rotation = lerp(rotation, Vector3.UP, 0.01)
		apply_central_force(20.0 * move_direction)
	if move_direction != Vector3.ZERO and move_input.y < 0.0:
		$RotationPivot.rotation.y = lerp_angle($RotationPivot.rotation.y, global_basis.z.signed_angle_to(move_direction, Vector3.UP), min(10.0 * state.step, 1.0))

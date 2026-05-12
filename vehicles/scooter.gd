class_name Scooter
extends Vehicle

@export var raycast : RayCast3D
@export var speed = 35.0


var move_input : Vector2 = Vector2.ZERO
var move_direction : Vector3 = Vector3.ZERO
var is_rising = false
var is_boosting = false

var _jump_lock_timer : SceneTreeTimer
var jump_lockout_time = 0.75

func _ready() -> void:
	super._ready()
	_jump_lock_timer = get_tree().create_timer(0.0)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not being_driven or not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	var scooter_forward = $RotationPivot.global_basis.z
	var scooter_right = $RotationPivot.global_basis.x
	var is_on_floor = raycast.is_colliding()
	if move_direction != Vector3.ZERO and move_input.y < 0.0:
		$RotationPivot.rotation.y = lerp_angle($RotationPivot.rotation.y, global_basis.z.signed_angle_to(move_direction, global_basis.y), min(10.0 * state.step, 1.0))
	if not is_on_floor:
		return
	var target_up = raycast.get_collision_normal()
	var forward = -global_basis.z

	# Strip the component of forward along target_up so it lies in
	# the tangent plane.
	forward = forward - target_up * forward.dot(target_up)

	# If that collapses (character was facing exactly along target_up),
	# pick any tangent direction as fallback.
	if forward.length_squared() < 0.0001:
		forward = global_basis.x.cross(target_up)
	var target_basis = Basis.looking_at(forward, target_up)

	# Frame-rate-independent exponential approach. orient_speed ~ 5–10 feels good;
	# higher = snappier. With this form, the character covers (1 - 1/e) ≈ 63%
	# of the remaining error in 1/orient_speed seconds.
	var t = 1.0 - exp(-20 * state.step)
	global_basis = global_basis.slerp(target_basis, t)

	var forward_vel = state.linear_velocity.project(scooter_forward)
	var perp_vel = state.linear_velocity.project(scooter_right)
	var kill_perp_vel_impulse = -perp_vel * mass
	apply_central_impulse(kill_perp_vel_impulse)
	var modified_speed = speed
	if is_boosting:
		modified_speed *= 2.0
	if move_direction.length() > 0.0:
		apply_central_force(modified_speed * scooter_forward * sign(move_direction.dot(scooter_forward)))
	if is_rising and _jump_lock_timer.time_left == 0.0:
		apply_central_impulse((100.0 - (linear_velocity.y * mass)) * global_basis.y)
		_jump_lock_timer = get_tree().create_timer(jump_lockout_time)

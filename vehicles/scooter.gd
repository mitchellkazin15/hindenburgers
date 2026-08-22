class_name Scooter
extends Vehicle

@export var raycast : RayCast3D
@export var speed = 35.0
@export var air_torque = 10.0
@export var left_raycast : RayCast3D
@export var right_raycast : RayCast3D

@export_group("Suspension")
## Where the scooter rides within the raycast's length.
## 0 = fully extended (ray tip on the ground), 1 = fully compressed (ray origin on the ground).
## Lower values raise the chassis; raise this once the collision shape has more ground clearance.
@export_range(0.05, 0.95, 0.01) var ride_offset := 0.25
## 1.0 is critically damped (settles without bouncing). Below 1 bounces, above 1 feels sluggish.
@export_range(0.0, 3.0, 0.05) var damping_ratio := 1.0
## Safety valve, in multiples of the scooter's own weight. Caps the spike the damper can
## produce when the ray distance jumps (a ledge lip, a mesh seam) and also caps how hard
## the suspension can ever launch the scooter off a bump.
@export_range(1.0, 10.0, 0.25) var max_force_multiplier := 4.0


var move_input : Vector2 = Vector2.ZERO
var move_direction : Vector3 = Vector3.ZERO
var is_rising = false
var is_boosting = false

var _jump_lock_timer : SceneTreeTimer
var jump_lockout_time = 1.0

## Previous frame's raycast contact distance, used to measure how fast the spring is
## compressing. Negative means "no reading yet" (airborne, or first grounded frame).
var _last_dist := -1.0

func _ready() -> void:
	super._ready()
	_jump_lock_timer = get_tree().create_timer(0.0)


func set_driver(driving_character: Character) -> bool:
	lock_rotation = false
	return super.set_driver(driving_character)


func _on_end_locked_interaction() -> void:
	super._on_end_locked_interaction()
	lock_rotation = true


func _apply_suspension(state: PhysicsDirectBodyState3D) -> void:
	var max_length := raycast.target_position.length()
	if max_length <= 0.0:
		return
	var origin := raycast.global_position
	var contact := raycast.get_collision_point()
	var normal := raycast.get_collision_normal()
	var dist : float = maxf((origin - contact).dot(normal), 0.0)
	var compression : float = clampf((max_length - dist) / max_length, 0.0, 1.0)
	var gravity : float
	if gravity_scale != 0.0:
		gravity = maxf(state.total_gravity.length(), 0.1)
	else:
		gravity = planet_gravity_accel
	var force_at_full_compression := mass * gravity / ride_offset
	var stiffness := force_at_full_compression / max_length			# newtons per metre
	var damping := 2.0 * damping_ratio * sqrt(stiffness * mass)		# newtons per m/s
	var compression_speed := 0.0
	if _last_dist >= 0.0 and state.step > 0.0:
		compression_speed = (_last_dist - dist) / state.step
	_last_dist = dist
	var force : float = force_at_full_compression * compression + damping * compression_speed
	var weight := mass * gravity
	force = clampf(force, 0.0, weight * max_force_multiplier)	# springs push, never pull
	state.apply_central_force(force * global_basis.y)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	var is_on_floor = raycast.is_colliding() and _jump_lock_timer.time_left == 0.0
	if is_on_floor:
		_apply_suspension(state)
	else:
		# Drop the stale reading so landing doesn't damp against a distance measured
		# before the scooter left the ground.
		_last_dist = -1.0
	if not being_driven:
		return
	if not is_on_floor:
		if left_raycast.is_colliding():
			state.apply_torque_impulse(10.0 * global_basis.z)
			state.apply_central_impulse(-20.0 * global_basis.x)
		elif right_raycast.is_colliding():
			state.apply_torque_impulse(-10.0 * global_basis.z)
			state.apply_central_impulse(20.0 * global_basis.x)
		else:
			state.apply_torque(-air_torque * move_input.y * global_basis.x)
			state.apply_torque(air_torque * move_input.x * global_basis.z)
			return
	var target_up = raycast.get_collision_normal()# scooter still flattens onto a slope).
	if target_up.length_squared() < 0.0001:
		# We only get here with no contact normal via the left/right recovery raycasts,
		# where the down ray is not touching anything. Keep the current up axis rather
		# than handing Basis.looking_at a zero vector.
		target_up = global_basis.y
	var desired_forward
	if move_direction.length_squared() > 0.0001:
		desired_forward = move_direction
	else:
		desired_forward = global_basis.z

	desired_forward = desired_forward - target_up * desired_forward.dot(target_up)
	desired_forward = desired_forward.normalized()
	var dir_sign = -1.0 if move_input.y == 0.0 else sign(move_input.y)
	var target_basis = Basis.looking_at(dir_sign * desired_forward, target_up)
	var t = 1.0 - exp(-3.0 * state.step)
	global_basis = global_basis.slerp(target_basis, t)

	# Build the drive axes on the contact plane instead of reusing the body basis. The
	# basis lags the terrain by the slerp's time constant, and at speed that lag is a real
	# angle: global_basis.z ends up tilted into the ground, so the drive force gets a
	# downward component, and global_basis.x picks up a vertical component, so killing
	# lateral velocity along it also kills the vertical velocity the suspension is trying
	# to build. Both grow with speed, which is what presses the scooter into the terrain.
	var forward := global_basis.z
	var ground_forward : Vector3 = forward - target_up * forward.dot(target_up)
	if ground_forward.length_squared() > 0.0001:
		ground_forward = ground_forward.normalized()
	else:
		ground_forward = forward
	var ground_right := target_up.cross(ground_forward).normalized()

	var perp_vel = state.linear_velocity.project(ground_right)
	var kill_perp_vel_impulse = -perp_vel * mass
	state.apply_central_impulse(kill_perp_vel_impulse)
	var modified_speed = speed
	if is_boosting:
		modified_speed *= 2.0
	if move_direction.length() > 0.0:
		state.apply_central_force(modified_speed * ground_forward * sign(move_direction.dot(ground_forward)))
	if is_rising and _jump_lock_timer.time_left == 0.0:
		state.apply_central_impulse(100.0 * global_basis.y)
		_jump_lock_timer = get_tree().create_timer(jump_lockout_time)
	state.angular_velocity = Vector3.ZERO

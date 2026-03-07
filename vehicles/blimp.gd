class_name Blimp
extends Vehicle


var move_input : Vector2 = Vector2.ZERO
var is_jumping = false
var speed = 100.0
var jump_speed = 20.0
var acceleration = 5.0
var upward_thrust = 10
var rotation_accel = 100
var righting_force = 5000
var gravity = 50
var terminal_speed = 1000.0


func _ready() -> void:
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
	var accel_scalar = abs(move_direction.dot(blimp_forward))
	state.apply_central_force(accel_scalar * acceleration * move_direction)
	var rotation_direction = (right * move_input.x).normalized()
	state.apply_torque(-1 * sign(move_input.x) * rotation_accel * Vector3(0, 1, 0))
	var righting_axis = global_basis.y.normalized().cross(Vector3.UP);
	state.apply_torque(righting_force * righting_axis)
	
	if is_jumping:
		state.apply_central_force(upward_thrust * Vector3.UP)
	if state.linear_velocity.length() > speed:
		state.linear_velocity = speed * state.linear_velocity.normalized()

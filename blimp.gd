class_name Blimp
extends RigidBody3D

@export var camera : Camera3D
var move_input : Vector2 = Vector2.ZERO
var is_jumping = false

var speed = 100.0
var jump_speed = 20.0
var acceleration = 5.0
var upward_thrust = 10
var rotation_accel = 100
var gravity = 50
var terminal_speed = 1000.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var forward = camera.global_basis.z
	var right = camera.global_basis.x
	var move_direction = forward * move_input.y
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	var ground_plane_move = Vector2(move_direction.x, move_direction.z)
	var blimp_forward = -global_basis.z
	var accel_scalar = abs(move_direction.dot(blimp_forward))
	print(accel_scalar)
	state.apply_central_force(accel_scalar * acceleration * move_direction)
	var rotation_direction = right * move_input.x
	state.apply_torque(-1 * sign(move_input.x) * rotation_accel * Vector3(0, 1, 0))
	#var to_angle = Vector2(move_direction.x, move_direction.z).angle() + (PI / 2.0)
	#var cross = rotation.cross(state.linear_velocity)
	#var torque_scalar = cross.length() * sign(cross.y)
	#state.apply_torque(rotation_accel * torque_scalar * Vector3(0, 1, 0))
	
	if is_jumping:
		#if state.linear_velocity.y == 0.0:
			#state.apply_central_impulse(upward_thrust * Vector3.UP)
		state.apply_central_force(upward_thrust * Vector3.UP)
	if state.linear_velocity.length() > speed:
		state.linear_velocity = speed * state.linear_velocity.normalized()

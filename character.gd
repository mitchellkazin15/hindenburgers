class_name Character
extends CharacterBody3D

@export var camera : Camera3D
var move_input : Vector2 = Vector2.ZERO
var is_jumping = false

var speed = 15.0
var jump_speed = 20.0
var acceleration = 25.0
var gravity = 50
var terminal_speed = 1000.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	var forward = camera.global_basis.z
	var right = camera.global_basis.x
	var move_direction = forward * move_input.y + right * move_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	var ground_plane_vel = Vector2(velocity.x, velocity.z)
	ground_plane_vel = ground_plane_vel.move_toward(speed * Vector2(move_direction.x, move_direction.z), acceleration * delta)
	velocity.x = ground_plane_vel.x
	velocity.z = ground_plane_vel.y
	velocity.y = min(terminal_speed, velocity.y - gravity * delta)
	if is_on_floor() and is_jumping:
		velocity.y = jump_speed
	move_and_slide()

class_name PlayerCamera3D
extends Camera3D

@export var _camera_pivot : Node3D
@export var tilt_upper_limit := PI / 2.0
@export var tilt_lower_limit := -PI / 2.0

var _camera_input_direction : Vector2
var mouse_sensitivity = 0.25


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		set_process(false)
		set_process_input(false)
		return
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity


func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO

class_name PlayerCamera3D
extends Camera3D

@export var _camera_pivot : Node3D
## Only used for plain Node3D pivots; CameraPivot owns its own clamp.
@export var tilt_upper_limit := deg_to_rad(89.9)
@export var tilt_lower_limit := deg_to_rad(-89.9)

var _camera_input_direction : Vector2
var mouse_sensitivity = 0.25


func _unhandled_input(event: InputEvent) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	if not current:
		return
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity


func _process(delta: float) -> void:
	if _camera_input_direction == Vector2.ZERO:
		return
	var yaw_delta := -_camera_input_direction.x * delta
	var pitch_delta := _camera_input_direction.y * delta
	_camera_input_direction = Vector2.ZERO

	if _camera_pivot is CameraPivot:
		(_camera_pivot as CameraPivot).add_look(yaw_delta, pitch_delta)
		return

	# Plain Node3D pivots (the vehicles) still rotate about world axes, so they
	# invert on the moon the way the character camera used to.
	_camera_pivot.rotation.x = clamp(
		_camera_pivot.rotation.x + pitch_delta, tilt_lower_limit, tilt_upper_limit
	)
	_camera_pivot.rotation.y += yaw_delta

class_name BlimpPlayerInputController
extends VehiclePlayerInputController

@export var blimp : Blimp
@export var camera : PlayerCamera3D


func _ready():
	if not blimp:
		blimp = get_parent()
	assert(blimp is Blimp)


func _unhandled_input(event):
	if not is_multiplayer_authority():
		return
	if not enabled:
		return
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var move_input = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down",
	).normalized()
	var forward = camera.global_basis.z
	var right = camera.global_basis.x
	var move_direction = forward * move_input.y
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	var is_rising = Input.is_action_pressed("jump")
	var is_boosting = Input.is_action_pressed("sprint")
	var reset_input = Input.is_action_pressed("reset")
	if reset_input:
		reset_physics_interpolation()
	_handle_input.rpc_id(1, move_input, move_direction, is_rising, is_boosting, reset_input)


@rpc("authority", "call_local", "unreliable_ordered")
func _handle_input(move_input, move_direction, is_rising, is_boosting, reset_input):
	blimp.move_input = move_input
	blimp.move_direction = move_direction
	blimp.is_rising = is_rising
	blimp.is_boosting = is_boosting
	if blimp.driver and reset_input:
		blimp.driver.reset()

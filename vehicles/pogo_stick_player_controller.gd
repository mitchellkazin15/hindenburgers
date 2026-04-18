class_name PogoStickPlayerInputController
extends VehiclePlayerInputController

@export var pogo_stick : PogoStick
@export var camera : PlayerCamera3D


func _ready():
	if not pogo_stick:
		pogo_stick = get_parent()
	assert(pogo_stick is PogoStick)


func _unhandled_input(event):
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	if not enabled:
		return
	if not camera and pogo_stick.being_driven:
		camera = pogo_stick.driver.camera
	if not camera:
		return
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
	var reset_input = Input.is_action_just_pressed("reset")
	#if reset_input:
		#reset_physics_interpolation()
	_handle_input.rpc_id(1, move_input, move_direction, is_rising, is_boosting, reset_input)


@rpc("authority", "call_local", "unreliable_ordered")
func _handle_input(move_input, move_direction, is_rising, is_boosting, reset_input):
	pogo_stick.move_input = move_input
	pogo_stick.move_direction = move_direction
	pogo_stick.is_rising = is_rising
	pogo_stick.is_boosting = is_boosting
	if pogo_stick.driver and reset_input:
		pogo_stick.driver.reset()

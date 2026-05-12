class_name ScooterPlayerInputController
extends VehiclePlayerInputController

@export var scooter : Scooter
@export var camera : PlayerCamera3D


func _ready():
	if not scooter:
		scooter = get_parent()
	assert(scooter is Scooter)


func _unhandled_input(event):
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	if not scooter.being_driven:
		return
	if not camera and scooter.being_driven:
		camera = scooter.driver.camera
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
	move_direction = move_direction.normalized()
	var is_rising = Input.is_action_pressed("jump")
	var is_boosting = Input.is_action_pressed("sprint")
	var reset_input = Input.is_action_just_pressed("reset")
	_handle_input.rpc_id(1, move_input, move_direction, is_rising, is_boosting, reset_input)


@rpc("authority", "call_local", "unreliable_ordered")
func _handle_input(move_input, move_direction, is_rising, is_boosting, reset_input):
	scooter.move_input = move_input
	scooter.move_direction = move_direction
	scooter.is_rising = is_rising
	scooter.is_boosting = is_boosting
	if scooter.driver and reset_input:
		scooter.driver.reset()

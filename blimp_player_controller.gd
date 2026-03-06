class_name BlimpPlayerController
extends Node

@export var blimp : Blimp
@export var enabled = false


func _ready():
	if not blimp:
		blimp = get_parent()
	assert(blimp is Blimp)


func _unhandled_input(event):
	if not is_multiplayer_authority():
		set_process(false)
		set_process_input(false)
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
	)
	blimp.move_input = move_input.normalized()
	if event.is_action_pressed("jump"):
		blimp.is_jumping = true
	if event.is_action_released("jump"):
		blimp.is_jumping = false

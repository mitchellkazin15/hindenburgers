class_name PlayerInputComponent
extends Node

@export var character : Character
@export var interacting_area : InteractingArea3D
@export var enabled = true


func _ready():
	if not character:
		character = get_parent()


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
	character.move_input = move_input.normalized()
	if event.is_action_pressed("jump"):
		character.is_jumping = true
	if event.is_action_released("jump"):
		character.is_jumping = false
	if event.is_action_pressed("interact") and character.locked_interaction:
		character.end_locked_interaction()
	elif event.is_action_pressed("interact") and interacting_area:
		for area in interacting_area.get_overlapping_areas():
			if area is InteractableArea3D:
				area.interact(character)
	if event.is_action_pressed("reset"):
		character.reset()
	

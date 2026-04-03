class_name CharacterPlayerInputController
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
		set_physics_process(false)
		set_process_input(false)
		return
	if not enabled:
		return
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		return
	var move_input = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down",
	)
	var is_jumping = Input.is_action_pressed("jump")
	var is_sprinting = Input.is_action_pressed("sprint")
	var forward = character.camera.global_basis.z
	var right = character.camera.global_basis.x
	var move_direction = forward * move_input.y + right * move_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	_handle_move_input.rpc_id(1, move_direction, is_jumping, is_sprinting)
	if Input.is_action_just_pressed("interact"):
		_handle_interact.rpc_id(1)
	if Input.is_action_just_pressed("throw") or Input.is_action_just_released("throw"):
		_handle_throw_input.rpc_id(1, Input.is_action_just_released("throw"))
	if Input.is_action_just_pressed("reset"):
		_handle_reset_input.rpc_id(1)
	if Input.is_action_just_pressed("use_item") or Input.is_action_just_released("use_item"):
		_handle_use_item_input.rpc_id(1, Input.is_action_just_released("use_item"))


@rpc("authority", "call_local", "unreliable_ordered")
func _handle_move_input(move_direction, is_jumping, is_sprinting):
	character.move_direction = move_direction
	character.is_jumping = is_jumping
	character.is_sprinting = is_sprinting


@rpc("authority", "call_local", "unreliable_ordered")
func _handle_interact():
	for area in interacting_area.get_overlapping_areas():
		if area is InteractableArea3D:
			area.interact(character)


@rpc("authority", "call_local", "reliable")
func _handle_throw_input(released : bool):
	if released:
		character.throw_item()
	else:
		character.start_throw_item()


@rpc("authority", "call_local", "reliable")
func _handle_reset_input():
	character.reset_input = true


@rpc("authority", "call_local", "reliable")
func _handle_use_item_input(released : bool):
	if released:
		character.use_item()
	else:
		character.start_use_item()

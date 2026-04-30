class_name CharacterPlayerInputController
extends Node

@export var character : Character
@export var interacting_raycast : InteractionRayCast3D
@export var enabled = true


func _ready():
	if not character:
		character = get_parent()


func _physics_process(delta: float) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
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
		_handle_interact.rpc_id(1, interacting_raycast.global_rotation)
	if Input.is_action_just_pressed("throw") or Input.is_action_just_released("throw"):
		_handle_throw_input.rpc_id(1, Input.is_action_just_released("throw"), -character.camera.global_basis.z)
	if Input.is_action_just_pressed("reset"):
		#reset_physics_interpolation()
		_handle_reset_input.rpc_id(1)
	if Input.is_action_just_pressed("use_item") or Input.is_action_just_released("use_item"):
		_handle_use_item_input.rpc_id(1, Input.is_action_just_released("use_item"))


@rpc("authority", "call_local", "unreliable_ordered")
func _handle_move_input(move_direction, is_jumping, is_sprinting):
	character.move_direction = move_direction
	character.is_jumping = is_jumping
	character.is_sprinting = is_sprinting


@rpc("authority", "call_local", "unreliable_ordered")
func _handle_interact(raycast_rotation : Vector3):
	if character.locked_interaction:
		character.end_locked_interaction.rpc()
		return
	interacting_raycast.global_rotation = raycast_rotation
	interacting_raycast.force_raycast_update()
	var interactable_area = interacting_raycast.get_interactable_area_collider()
	if interactable_area:
		interactable_area.interact(character)


@rpc("authority", "call_local", "reliable")
func _handle_throw_input(released : bool, aim_dir : Vector3):
	if released:
		character.throw_item(aim_dir)
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

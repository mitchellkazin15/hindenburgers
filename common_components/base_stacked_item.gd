class_name BaseStackedItem
extends HoldableItem

@export var grab_item_area : GrabItemArea3D
@export var stack_item_area : StackableItemArea3D

var effects : Array[ItemEffect] = []
var stack_count = 0
## Positions and rotations are relative to this stack
var stacked_scenes = []
var stacked_scene_positions = []
var stacked_scene_rotations = []
var pending_stack_data = []


func _ready() -> void:
	super._ready()
	if pending_stack_data:
		rebuild_stack(pending_stack_data[0], pending_stack_data[1], pending_stack_data[2])
		pending_stack_data = []


func get_stack_data() -> Array:
	return [stacked_scenes.duplicate(), stacked_scene_positions.duplicate(), stacked_scene_rotations.duplicate()]


## Server only. Returns [scenes, positions, rotations] of [param item] relative to this stack
func get_stack_data_for(item : HoldableItem) -> Array:
	var to_local := global_transform.affine_inverse() * item.global_transform
	if not item is BaseStackedItem:
		return [[item.scene_file_path], [to_local.origin], [to_local.basis.orthonormalized().get_euler()]]
	var positions = []
	var rotations = []
	for i in item.stacked_scenes.size():
		var entry_transform = to_local * Transform3D(Basis.from_euler(item.stacked_scene_rotations[i]), item.stacked_scene_positions[i])
		positions.append(entry_transform.origin)
		rotations.append(entry_transform.basis.orthonormalized().get_euler())
	return [item.stacked_scenes.duplicate(), positions, rotations]


## Server only
func add_to_stack(stack_data : Array):
	rebuild_stack.rpc(
		stacked_scenes + stack_data[0],
		stacked_scene_positions + stack_data[1],
		stacked_scene_rotations + stack_data[2],
	)


## Server only
func sync_stack_to_peer(peer_id : int):
	rebuild_stack.rpc_id(peer_id, stacked_scenes, stacked_scene_positions, stacked_scene_rotations)


## Instantiates every stacked scene this stack doesn't have yet and absorbs its nodes.
## Every peer builds the stack the same way, so node names match across peers.
@rpc("authority", "call_local", "reliable")
func rebuild_stack(scenes : Array, positions : Array, rotations : Array):
	for i in range(stacked_scenes.size(), scenes.size()):
		_absorb_scene(scenes[i], Transform3D(Basis.from_euler(rotations[i]), positions[i]))
		stacked_scenes.append(scenes[i])
		stacked_scene_positions.append(positions[i])
		stacked_scene_rotations.append(rotations[i])


func _absorb_scene(scene_path : String, item_transform : Transform3D):
	var item : HoldableItem = load(scene_path).instantiate()
	var stackable_area : StackableItemArea3D = null
	for child in item.get_children():
		if child is StackableItemArea3D:
			stackable_area = child
	_merge_item_values(item, stackable_area)
	for node in stackable_area.get_transfer_list():
		_absorb_node(item, node, item_transform)
	_absorb_node(item, stackable_area, item_transform)
	item.free()


func _merge_item_values(item : HoldableItem, stackable_area : StackableItemArea3D):
	max_use_charge_time = max(max_use_charge_time, item.max_use_charge_time)
	mass += item.mass
	unlock_rotation_on_use = unlock_rotation_on_use or item.unlock_rotation_on_use
	reset_rotation_when_grabbed = reset_rotation_when_grabbed or (stackable_area.override_reset_rotation_when_grabbed and item.reset_rotation_when_grabbed)
	for node in stackable_area.additional_transfer_list:
		if not node in stack_item_area.additional_transfer_list:
			stack_item_area.additional_transfer_list.append(node)


func _absorb_node(item : HoldableItem, node : Node, item_transform : Transform3D):
	stack_count += 1
	if node is GrabItemArea3D or node is StackableItemArea3D:
		var area_parent = grab_item_area if node is GrabItemArea3D else stack_item_area
		for child in node.get_children():
			if child is CollisionShape3D:
				_move_node(child, area_parent, item_transform * _transform_in(child, item))
		return
	elif node is ItemEffect:
		if not _merge_into_existing_effect(node):
			_move_node(node, self, Transform3D.IDENTITY)
		return
	elif node is CollisionShape3D and not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	_move_node(node, self, item_transform * _transform_in(node, item))
	if node is CollisionShape3D:
		old_collision_children.append(node)


func _move_node(node : Node, new_parent : Node, stack_space_transform : Transform3D):
	node.owner = null
	node.get_parent().remove_child(node)
	if node is Node3D:
		node.transform = _transform_in(new_parent, self).affine_inverse() * stack_space_transform
	new_parent.add_child(node, true)
	node.owner = new_parent


func _transform_in(node : Node, root : Node) -> Transform3D:
	var result := Transform3D.IDENTITY
	while node != root:
		if node is Node3D:
			result = node.transform * result
		node = node.get_parent()
	return result


func _merge_into_existing_effect(new_effect : ItemEffect) -> bool:
	var consume_effect : ConsumeEffect = null
	for effect in effects:
		if effect is ConsumeEffect:
			consume_effect = effect
	if new_effect is ConsumeEffect and consume_effect:
		consume_effect.uses = min(consume_effect.uses, new_effect.uses)
		return true
	return false

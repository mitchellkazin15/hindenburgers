class_name BaseStackedItem
extends HoldableItem

@export var grab_item_area : GrabItemArea3D
@export var stack_item_area : StackableItemArea3D

var effects : Array[ItemEffect] = []
var stack_count = 0


@rpc("any_peer", "call_local", "reliable")
func merge_item_values(item_path : NodePath, item_stackable_area_path : NodePath):
	var item : HoldableItem = get_node(item_path)
	var stackable_area : StackableItemArea3D = get_node(item_stackable_area_path)
	max_use_charge_time = max(max_use_charge_time, item.max_use_charge_time)
	mass += item.mass
	unlock_rotation_on_use = unlock_rotation_on_use or item.unlock_rotation_on_use
	reset_rotation_when_grabbed = reset_rotation_when_grabbed or (stackable_area.override_reset_rotation_when_grabbed and item.reset_rotation_when_grabbed)
	for node in stackable_area.additional_transfer_list:
		if not node in stack_item_area.additional_transfer_list:
			stack_item_area.additional_transfer_list.append(node)


@rpc("any_peer", "call_local", "reliable")
func replicate_stack(path : NodePath, server_position, server_rotation):
	if not has_node(path):
		return
	stack_count += 1
	var node = get_node(path)
	if node is GrabItemArea3D or node is StackableItemArea3D:
		var area_parent = grab_item_area if node is GrabItemArea3D else stack_item_area
		for child in node.get_children():
			if not child is CollisionShape3D:
				continue
			handle_reparent(area_parent, child, server_position, server_rotation)
		return
	elif node is ItemEffect:
		merge_effects(node, server_position, server_rotation)
		return
	elif node is CollisionShape3D and not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	else:
		handle_reparent(self, node, server_position, server_rotation)


func handle_reparent(new_parent, node : Node, server_position, server_rotation):
	if MultiplayerManager.safe_is_multiplayer_authority(self):
		node.reparent(new_parent, true)
	else:
		node.reparent(new_parent, false)
		if server_position and server_rotation:
			node.global_position = server_position
			node.global_rotation = server_rotation
	node.owner = new_parent


func merge_effects(new_effect: ItemEffect, server_position, server_rotation):
	var consume_effect : ConsumeEffect = null
	for effect in effects:
		if effect is ConsumeEffect:
			consume_effect = effect
	if new_effect is ConsumeEffect and consume_effect:
		consume_effect.uses = min(consume_effect.uses, new_effect.uses)
	else:
		handle_reparent(self, new_effect, server_position, server_rotation)
		new_effect.on_reparent()

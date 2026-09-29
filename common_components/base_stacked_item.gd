class_name BaseStackedItem
extends HoldableItem

@export var grab_item_area : GrabItemArea3D
@export var stack_item_area : StackableItemArea3D

var effects : Array[ItemEffect] = []


@rpc("any_peer", "call_local", "reliable")
func replicate_stack(path : NodePath, server_position, server_rotation):
	if not has_node(path):
		return
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

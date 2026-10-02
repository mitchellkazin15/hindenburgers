class_name StackableItemArea3D
extends Area3D

## If true, when stacking, transfer all meshes, collsion shapes, grab item area
## and item effects that are direct children of the parent body
@export var use_default_transfers = true
@export var additional_transfer_list : Array[Node] =[]
@export var can_stack_same_type = false
@export var override_reset_rotation_when_grabbed = false

var parent_body : HoldableItem:
	get:
		return get_parent()
var pause_for_frame = false


func _physics_process(delta: float) -> void:
	if parent_body.being_held:
		return
	for area in get_overlapping_areas():
		_on_area_entered(area)


func _on_area_entered(area):
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	if not area is StackableItemArea3D:
		print("This shouldn't be in the stackable_area layer: ", area)
		return
	if pause_for_frame:
		print("pausing one frame")
		pause_for_frame = false
		return
	var stackable_area := area as StackableItemArea3D
	var stacked_body : BaseStackedItem
	if stackable_area.parent_body.being_held:
		return
	if parent_body is BaseStackedItem and not stackable_area.parent_body is BaseStackedItem:
		# node transfer will be handled by other areas callback
		return
	elif not parent_body is BaseStackedItem and not stackable_area.parent_body is BaseStackedItem:
		if not can_stack_same_type and stackable_area.parent_body.scene_file_path == parent_body.scene_file_path:
			return
		stacked_body = MultiplayerManager.add_node_to_spawner("res://common_components/base_stacked_item.tscn", self.global_position, self.global_rotation)
		stackable_area.pause_for_frame = true
	elif not parent_body is BaseStackedItem and stackable_area.parent_body is BaseStackedItem:
		stacked_body = stackable_area.parent_body
	elif (parent_body as BaseStackedItem).stack_count <= (stackable_area.parent_body as BaseStackedItem).stack_count:
		stacked_body = stackable_area.parent_body
		if (parent_body as BaseStackedItem).stack_count == (stackable_area.parent_body as BaseStackedItem).stack_count:
			stackable_area.pause_for_frame = true
	else:
		# At this point both items are already stacks.
		# This item has a strictly larger stack so node transfer will be handled by other areas callback
		return
	stacked_body.merge_item_values.rpc(parent_body.get_path(), stackable_area.get_path())
	transfer_nodes(stacked_body)


func transfer_nodes(stacked_body : BaseStackedItem):
	for node : Node in get_transfer_list():
		if node is Node3D:
			stacked_body.replicate_stack.rpc(node.get_path(), node.global_position, node.global_rotation)
		else:
			stacked_body.replicate_stack.rpc(node.get_path(), null, null)
		if node is CollisionShape3D:
			stacked_body.old_collision_children.append(node)
	stacked_body.replicate_stack.rpc(self.get_path(), self.global_position, self.global_rotation)
	MultiplayerManager.broadcast_queue_free(parent_body)


func get_transfer_list() -> Array[Node]:
	var transfer_list : Array[Node] = []
	if use_default_transfers:
		for child in parent_body.get_children():
			if (child is MeshInstance3D or 
				child is CollisionShape3D or 
				child is GrabItemArea3D or 
				child is ItemEffect
			):
				transfer_list.append(child)
	transfer_list.append_array(additional_transfer_list)
	print("transferring ", transfer_list)
	return transfer_list

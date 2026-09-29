class_name StackableItemArea3D
extends Area3D

@export var transfer_nodes : Array[Node]
@export var can_stack_same_type = false

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
	print("stacking ", parent_body, " into ", stacked_body)
	for node : Node in transfer_nodes:
		if node is Node3D:
			stacked_body.replicate_stack.rpc(node.get_path(), node.global_position, node.global_rotation)
		else:
			stacked_body.replicate_stack.rpc(node.get_path(), null, null)
		if node is CollisionShape3D:
			stacked_body.old_collision_children.append(node)
	stacked_body.mass += parent_body.mass
	stacked_body.replicate_stack.rpc(self.get_path(), self.global_position, self.global_rotation)
	MultiplayerManager.broadcast_queue_free(parent_body)

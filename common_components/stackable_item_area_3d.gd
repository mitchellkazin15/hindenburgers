class_name StackableItemArea3D
extends Area3D

@export var original_body : RelativeRigidBody3D
@export var stacked_body : BaseStackedItem
@export var transfer_nodes : Array[Node]
@export var can_stack_same_type = false

var stacked = false


func _physics_process(delta: float) -> void:
	if original_body is HoldableItem and (original_body as HoldableItem).being_held:
		return
	for area in get_overlapping_areas():
		_on_area_entered(area)


func _on_area_entered(area):
	if not MultiplayerManager.safe_is_multiplayer_authority(self) or stacked:
		return
	if not area is StackableItemArea3D:
		print("This shouldn't be in the stackable_area layer: ", area)
		return
	var stackable_area := area as StackableItemArea3D
	if not stackable_area.stacked:
		if not can_stack_same_type and stackable_area.original_body.scene_file_path == original_body.scene_file_path:
			return
		stacked_body = MultiplayerManager.add_node_to_spawner("res://common_components/base_stacked_item.tscn", self.global_position, self.global_rotation)
	else:
		stacked_body = stackable_area.stacked_body
	for node : Node in transfer_nodes:
		if node is Node3D:
			stacked_body.replicate_stack.rpc(node.get_path(), node.global_position, node.global_rotation)
		else:
			stacked_body.replicate_stack.rpc(node.get_path(), null, null)
		if node is CollisionShape3D:
			stacked_body.old_collision_children.append(node)
	stacked_body.replicate_stack.rpc(self.get_path(), self.global_position, self.global_rotation)
	stacked_body.mass += original_body.mass
	MultiplayerManager.broadcast_queue_free(original_body)
	stacked = true

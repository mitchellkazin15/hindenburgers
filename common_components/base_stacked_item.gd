class_name BaseStackedItem
extends EdibleItem

@export var grab_item_area : GrabItemArea3D


@rpc("any_peer", "call_local", "reliable")
func replicate_stack(path : NodePath, server_position, server_rotation):
	if not has_node(path):
		return
	var node = get_node(path)
	if node is GrabItemArea3D:
		for child in node.get_children():
			if not child is CollisionShape3D:
				continue
			handle_reparent(grab_item_area, child, server_position, server_rotation)
		return
	handle_reparent(self, node, server_position, server_rotation)


func handle_reparent(new_parent, node : Node3D, server_position, server_rotation):
	if MultiplayerManager.safe_is_multiplayer_authority(self):
		node.reparent(new_parent, true)
	else:
		node.reparent(new_parent, false)
		node.global_position = server_position
		node.global_rotation = server_rotation
	node.owner = new_parent

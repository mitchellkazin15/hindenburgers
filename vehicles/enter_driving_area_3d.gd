class_name EnterDrivingArea3D
extends InteractableArea3D

@export var vehicle : Vehicle


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character or not vehicle.driver == null:
		return
	var character : Character = interacting_node
	character.set_locked_interacting()
	print("interact called by: ", multiplayer.get_unique_id())
	print("driver is: ", interacting_node.multiplayer.get_unique_id())
	vehicle.set_driver(character)
	vehicle.update_authority.rpc(character.get_multiplayer_authority())

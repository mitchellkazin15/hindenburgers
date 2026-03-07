class_name EnterDrivingArea3D
extends InteractableArea3D

@export var vehicle : Vehicle


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character or not vehicle.driver == null:
		return
	var character : Character = interacting_node
	character.set_locked_interacting()
	vehicle.set_driver.rpc(character)

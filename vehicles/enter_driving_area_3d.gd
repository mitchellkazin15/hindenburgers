class_name EnterDrivingArea3D
extends InteractableArea3D

@export var vehicle : Vehicle


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character or not vehicle.driver == null:
		return
	var character : Character = interacting_node
	if vehicle.set_driver(character):
		character.set_locked_interacting()

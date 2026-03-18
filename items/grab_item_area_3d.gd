class_name GrabItemArea3D
extends InteractableArea3D

@export var item : HoldableItem


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character or item.being_held:
		return
	var character : Character = interacting_node
	if character.grab_item(item):
		item.set_being_held()

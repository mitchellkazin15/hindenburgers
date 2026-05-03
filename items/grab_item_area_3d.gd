class_name GrabItemArea3D
extends InteractableArea3D

@export var item : HoldableItem
var light : OmniLight3D


func _ready() -> void:
	if has_node("OmniLight3D"):
		light = get_node("OmniLight3D")
		light.hide()


func set_glow():
	if item.being_held:
		light.hide()
		return
	if light:
		light.show()


func remove_glow():
	if light:
		light.hide()


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character or item.being_held:
		return
	var character : Character = interacting_node
	if character.grab_item(item):
		item.set_being_held(character)

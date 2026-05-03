class_name EnterDrivingArea3D
extends InteractableArea3D

@export var vehicle : Vehicle
var light : OmniLight3D


func _ready() -> void:
	if has_node("OmniLight3D"):
		light = get_node("OmniLight3D")
		light.hide()


func set_glow():
	if vehicle.being_driven:
		light.hide()
		return
	if light:
		light.show()


func remove_glow():
	if light:
		light.hide()


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character:
		return
	var character : Character = interacting_node
	if character == vehicle.driver:
		character.end_locked_interaction.rpc()
		#character.end_locked_interaction.rpc_id(character.camera.get_multiplayer_authority())
	elif vehicle.set_driver(character):
		character.set_locked_interacting(vehicle.camera != null, vehicle)

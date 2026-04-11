class_name EnterDrivingArea3D
extends InteractableArea3D

@export var vehicle : Vehicle


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character:
		return
	var character : Character = interacting_node
	if character == vehicle.driver:
		character.end_locked_interaction.rpc()
		#character.end_locked_interaction.rpc_id(character.camera.get_multiplayer_authority())
	elif vehicle.set_driver(character):
		character.set_locked_interacting(vehicle.camera != null, vehicle)

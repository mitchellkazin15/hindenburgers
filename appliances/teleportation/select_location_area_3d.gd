class_name SelectLocationArea3D
extends InteractableArea3D

@export var enabled = false
@export var location_index : int
@export var label : Label3D


func set_glow():
	label.outline_modulate = Color(0.0, 0.5, 0.0, 1.0)


func remove_glow():
	label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)


func interact(interacting_node: Node) -> void:
	if not enabled or not interacting_node is Character or not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	var character : Character = interacting_node
	TeleportationManager.teleport_character(character, location_index)

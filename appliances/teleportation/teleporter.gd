class_name Teleporter
extends StaticBody3D

@export var location_name : String
@export var teleport_spawn : Node3D
@export var teleporter_index : int
@export var unlocked = false
@export var location_list : Node3D


func _ready() -> void:
	assert(teleporter_index < TeleportationManager.MAX_TELEPORTERS)
	TeleportationManager.register_teleporter(self)


func _process(delta: float) -> void:
	for index in TeleportationManager.teleporters.keys():
		var teleporter = TeleportationManager.teleporters[index]
		var location_selection : TeleportationLocation = location_list.get_node("Location%d" % [index])
		location_selection.set_location(teleporter)
		location_selection.set_selection_active(teleporter.unlocked)

class_name TeleportationLocation
extends Node3D

@export var selection_area : SelectLocationArea3D



func _ready() -> void:
	set_selection_active(false)


func set_location(teleporter : Teleporter):
	selection_area.location_index = teleporter.teleporter_index
	selection_area.label.text = teleporter.location_name


func set_selection_active(active : bool):
	if active:
		selection_area.enabled = true
		self.show()
	else:
		selection_area.enabled = false
		self.hide()

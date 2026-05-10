extends Node

const MAX_TELEPORTERS = 10

var teleporters : Dictionary[int, Teleporter]


func register_teleporter(teleporter : Teleporter):
	assert(not teleporter.teleporter_index in teleporters.keys())
	teleporters[teleporter.teleporter_index] = teleporter
	assert(teleporters.keys().size() <= MAX_TELEPORTERS)


func teleport_character(character : Character, new_index : int):
	var new_tp_loc = teleporters[new_index]
	if new_tp_loc.unlocked:
		character.global_position = new_tp_loc.teleport_spawn.global_position

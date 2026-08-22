extends Node

const MAX_TELEPORTERS = 10

var teleporters : Dictionary[int, Teleporter]
var unlocks : Dictionary[int, bool]


func register_teleporter(teleporter : Teleporter):
	assert(not teleporter.teleporter_index in teleporters.keys())
	teleporters[teleporter.teleporter_index] = teleporter
	print("unlocks", unlocks)
	if teleporter.teleporter_index in unlocks.keys():
		teleporter.unlocked = unlocks[teleporter.teleporter_index]
	assert(teleporters.keys().size() <= MAX_TELEPORTERS)


func teleport_character(character : Character, new_index : int):
	var new_tp_loc = teleporters[new_index]
	if new_tp_loc.unlocked:
		character.global_position = new_tp_loc.teleport_spawn.global_position
		character.global_rotation = new_tp_loc.teleport_spawn.global_rotation


func load_teleporter_unlocks(unlocks_dict : Dictionary[int, bool]):
	print("teleporter", teleporters)
	unlocks = unlocks_dict
	for i in unlocks_dict.keys():
		print("unlocking ", teleporters[i])
		teleporters[i].unlocked = unlocks_dict[i]


func generate_unlock_save_dict() -> Dictionary[int, bool]:
	var save_dict : Dictionary[int, bool] = {}
	for i in teleporters.keys():
		save_dict[i] = teleporters[i].unlocked
	return save_dict

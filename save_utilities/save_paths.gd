class_name SavePaths
extends Object

## Every file the game writes at runtime lives here.
##
## This used to be res://save_files/. res:// is read-only in an exported build,
## so every ResourceSaver.save() below silently failed once the game was packaged;
## user:// is the only writable location.
const SAVE_DIR = "user://save_files/"

const SETTINGS = SAVE_DIR + "current_settings.tres"
const LEVEL = SAVE_DIR + "level_save_file.tres"
const BASE_LEVEL = SAVE_DIR + "base_level.tscn"
## Scratch path for the write-then-rename swap in LevelSaveManager.
const BASE_LEVEL_TMP = SAVE_DIR + "base_level_tmp.tscn"
const CHARACTER = SAVE_DIR + "character_save_file.tres"
const HOST_GAME_DEFAULTS = SAVE_DIR + "host_game_defaults.tres"
const JOIN_GAME_DEFAULTS = SAVE_DIR + "join_game_defaults.tres"

const LEGACY_SAVE_DIR = "res://save_files/"


## Call before writing anything. Creates the directory on first run and carries
## across any saves left over from when they lived in res://save_files/.
static func ensure_dir() -> void:
	if DirAccess.dir_exists_absolute(SAVE_DIR):
		return
	if DirAccess.make_dir_recursive_absolute(SAVE_DIR) != OK:
		push_error("could not create " + SAVE_DIR)
		return
	_migrate_legacy_saves()


static func _migrate_legacy_saves() -> void:
	var legacy_dir = DirAccess.open(LEGACY_SAVE_DIR)
	if legacy_dir == null:
		return
	for file_name in legacy_dir.get_files():
		if file_name.ends_with(".import") or file_name.ends_with(".uid"):
			continue
		DirAccess.copy_absolute(LEGACY_SAVE_DIR + file_name, SAVE_DIR + file_name)

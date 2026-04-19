extends Node

signal new_settings

const DEFAULT_SETTINGS_PATH = "res://autoloads/settings/default_settings.tres"
const SAVE_FILES_PATH = "res://save_files/"
const SAVED_SETTINGS_PATH = "res://save_files/current_settings.tres"

var current_settings : SettingsFile
var default_settings : SettingsFile


func _ready():
	default_settings = load(DEFAULT_SETTINGS_PATH)
	load_settings()


func load_settings():
	var res_dir = DirAccess.open("res://")
	if not res_dir.dir_exists(SAVE_FILES_PATH):
		res_dir.make_dir(SAVE_FILES_PATH)
	if not res_dir.file_exists(SAVED_SETTINGS_PATH):
		DirAccess.copy_absolute(DEFAULT_SETTINGS_PATH, SAVED_SETTINGS_PATH)
	current_settings = ResourceLoader.load(SAVED_SETTINGS_PATH, "SettingsFile", 0)
	DisplayServer.window_set_mode(SettingsFile.WindowMode.values()[current_settings.window_mode])
	new_settings.emit


func save_new_settings(new_settings):
	ResourceSaver.save(new_settings, SAVED_SETTINGS_PATH)
	load_settings()


func get_true_music_volume_db(base_volume_linear):
	if current_settings.mute:
		return linear_to_db(0.0)
	return linear_to_db(
		current_settings.master_volume_linear *
		current_settings.music_volume_linear *
		base_volume_linear
	)


func get_true_sfx_volume_db(base_volume_linear):
	if current_settings.mute:
		return linear_to_db(0.0)
	return linear_to_db(
		current_settings.master_volume_linear *
		current_settings.sfx_volume_linear *
		base_volume_linear
	)


func get_window_mode():
	return current_settings.window_mode


func get_muted():
	return current_settings.mute


func get_master_volume_linear():
	return current_settings.master_volume_linear


func get_music_volume_linear():
	return current_settings.music_volume_linear


func get_sfx_volume_linear():
	return current_settings.sfx_volume_linear


func get_default_window_mode():
	return default_settings.window_mode


func get_default_muted():
	return default_settings.mute


func get_default_master_volume_linear():
	return default_settings.master_volume_linear


func get_default_music_volume_linear():
	return default_settings.music_volume_linear


func get_default_sfx_volume_linear():
	return default_settings.sfx_volume_linear

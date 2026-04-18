class_name HostGameMenu
extends BaseMenu

const SAVED_HOST_GAME_DEFAULTS_PATH = "res://save_files/host_game_defaults.tres"

@export var name_field : TextEdit
@export var host_button : HostGameButton


func _ready():
	super._ready()
	host_button.pressed.connect(_on_join_game_pressed)
	var res_dir = DirAccess.open("res://")
	if not res_dir.dir_exists(Settings.SAVE_FILES_PATH):
		res_dir.make_dir(Settings.SAVE_FILES_PATH)
	if not res_dir.file_exists(SAVED_HOST_GAME_DEFAULTS_PATH):
		return
	var host_game_defaults = ResourceLoader.load(SAVED_HOST_GAME_DEFAULTS_PATH, "HostGameDefaults", 0)
	name_field.text = host_game_defaults.name


func _on_join_game_pressed():
	var new_defaults = JoinGameDefaults.new()
	new_defaults.name = name_field.text
	ResourceSaver.save(new_defaults, SAVED_HOST_GAME_DEFAULTS_PATH)

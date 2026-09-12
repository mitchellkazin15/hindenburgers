class_name HostGameMenu
extends BaseMenu

const SAVED_HOST_GAME_DEFAULTS_PATH = SavePaths.HOST_GAME_DEFAULTS

@export var name_field : TextEdit
@export var host_button : HostGameButton


func _ready():
	super._ready()
	host_button.pressed.connect(_on_join_game_pressed)
	SavePaths.ensure_dir()
	if not FileAccess.file_exists(SAVED_HOST_GAME_DEFAULTS_PATH):
		return
	var host_game_defaults = ResourceLoader.load(SAVED_HOST_GAME_DEFAULTS_PATH, "HostGameDefaults", 0)
	name_field.text = host_game_defaults.name


func _on_join_game_pressed():
	var new_defaults = JoinGameDefaults.new()
	new_defaults.name = name_field.text
	SavePaths.ensure_dir()
	ResourceSaver.save(new_defaults, SAVED_HOST_GAME_DEFAULTS_PATH)

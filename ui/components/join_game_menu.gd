class_name JoinGameMenu
extends BaseMenu

const SAVED_JOIN_GAME_DEFAULTS_PATH = SavePaths.JOIN_GAME_DEFAULTS

@export var ip_field : TextEdit
@export var name_field : TextEdit
@export var join_button : JoinGameButton


func _ready():
	super._ready()
	join_button.pressed.connect(_on_join_game_pressed)
	SavePaths.ensure_dir()
	if not FileAccess.file_exists(SAVED_JOIN_GAME_DEFAULTS_PATH):
		return
	var join_game_defaults = ResourceLoader.load(SAVED_JOIN_GAME_DEFAULTS_PATH, "JoinGameDefaults", 0)
	ip_field.text = join_game_defaults.host
	name_field.text = join_game_defaults.name


func _on_join_game_pressed():
	var new_defaults = JoinGameDefaults.new()
	new_defaults.host = ip_field.text
	new_defaults.name = name_field.text
	SavePaths.ensure_dir()
	ResourceSaver.save(new_defaults, SAVED_JOIN_GAME_DEFAULTS_PATH)

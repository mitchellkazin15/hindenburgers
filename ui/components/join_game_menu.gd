class_name JoinGameMenu
extends BaseMenu

const SAVED_JOIN_GAME_DEFAULTS_PATH = "res://save_files/join_game_defaults.tres"

@export var ip_field : TextEdit
@export var name_field : TextEdit
@export var join_button : JoinGameButton


func _ready():
	super._ready()
	join_button.pressed.connect(_on_join_game_pressed)
	var res_dir = DirAccess.open("res://")
	if not res_dir.dir_exists(Settings.SAVE_FILES_PATH):
		res_dir.make_dir(Settings.SAVE_FILES_PATH)
	if not res_dir.file_exists(SAVED_JOIN_GAME_DEFAULTS_PATH):
		return
	var join_game_defaults = ResourceLoader.load(SAVED_JOIN_GAME_DEFAULTS_PATH, "JoinGameDefaults", 0)
	ip_field.text = join_game_defaults.host
	name_field.text = join_game_defaults.name


func _on_join_game_pressed():
	var new_defaults = JoinGameDefaults.new()
	new_defaults.host = ip_field.text
	new_defaults.name = name_field.text
	ResourceSaver.save(new_defaults, SAVED_JOIN_GAME_DEFAULTS_PATH)

class_name CharacterSaveManager
extends Node

const SAVED_CHARACTER_FILE_PATH = "res://save_files/character_save_file.tres"

@export var character : Character
@export var auto_save_interval = 10.0

var auto_save_timer : SceneTreeTimer


func _ready() -> void:
	auto_save_timer = get_tree().create_timer(0.0)
	send_save_file_vals_to_server()


@rpc("any_peer", "call_local", "reliable")
func load_character_values(serialized_val_list : Array):
	if not MultiplayerManager.safe_is_server():
		return
	var save_file : CharacterSaveFile = CharacterSaveFile.deserialize(serialized_val_list)
	if character.has_node("CoinPurse"):
		var purse : CoinPurse = character.get_node("CoinPurse")
		purse.money_val = save_file.coin_purse_money_val


func save_character_values():
	if multiplayer.get_unique_id() != character.initial_multiplayer_authority:
		return
	var character_save = CharacterSaveFile.new()
	if character.has_node("CoinPurse"):
		var purse : CoinPurse = character.get_node("CoinPurse")
		character_save.coin_purse_money_val = purse.money_val
	ResourceSaver.save(character_save, SAVED_CHARACTER_FILE_PATH)


func send_save_file_vals_to_server():
	if multiplayer.get_unique_id() != character.initial_multiplayer_authority:
		return
	var res_dir = DirAccess.open("res://")
	if not res_dir.file_exists(SAVED_CHARACTER_FILE_PATH):
		return
	var character_save_file : CharacterSaveFile = ResourceLoader.load(SAVED_CHARACTER_FILE_PATH, "CharacterSaveFile", 0)
	load_character_values.rpc_id(1, character_save_file.serialize())


func _physics_process(delta: float) -> void:
	if auto_save_timer.time_left != 0.0:
		return
	auto_save_timer = get_tree().create_timer(auto_save_interval)
	save_character_values()

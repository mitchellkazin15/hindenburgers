class_name MainMenuButton
extends Button

@export_file_path var main_menu_path = "res://ui/title_menu.tscn"
@export var disconnect_multiplayer = true


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	if EventService.state == EventService.GameState.IN_GAME:
		var character = EventService.find_player_by_peer(multiplayer.get_unique_id())
		if character and character.has_node("CharacterSaveManager"):
			var save_manager : CharacterSaveManager = character.get_node("CharacterSaveManager")
			save_manager.save_character_values()
	EventService.return_to_menu()
	EventService.change_menu_overlay.emit(main_menu_path)
	if disconnect_multiplayer:
		if multiplayer.is_server():
			EventService.clear_level_root()
		MultiplayerManager.remove_multiplayer_peer()

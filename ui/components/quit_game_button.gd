class_name QuitGameButton
extends Button


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	if EventService.state == EventService.GameState.IN_GAME:
		var character = EventService.find_player_by_peer(multiplayer.get_unique_id())
		if character and character.has_node("CharacterSaveManager"):
			var save_manager : CharacterSaveManager = character.get_node("CharacterSaveManager")
			save_manager.save_character_values()
	EventService.quit_game.emit()

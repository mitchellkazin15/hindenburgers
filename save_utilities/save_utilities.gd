class_name SaveUtilities
extends Object


static func save_character_and_or_level(peer_id):
	if EventService.state == EventService.GameState.IN_GAME:
		var character = EventService.find_player_by_peer(peer_id)
		if character and character.has_node("CharacterSaveManager"):
			var save_manager : CharacterSaveManager = character.get_node("CharacterSaveManager")
			save_manager.save_character_values()
		if peer_id == 1:
			LevelSaveManager.save_level()

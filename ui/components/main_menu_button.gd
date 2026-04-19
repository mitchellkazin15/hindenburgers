class_name MainMenuButton
extends Button

@export_file_path var main_menu_path = "res://ui/title_menu.tscn"
@export var disconnect_multiplayer = true


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	SaveUtilities.save_character_and_or_level(multiplayer.get_unique_id())
	EventService.return_to_menu()
	EventService.change_menu_overlay.emit(main_menu_path)
	if disconnect_multiplayer:
		if MultiplayerManager.safe_is_server():
			EventService.clear_level_root()
		MultiplayerManager.remove_multiplayer_peer()

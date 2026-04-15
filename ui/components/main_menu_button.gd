class_name MainMenuButton
extends Button

@export_file_path var main_menu_path = "res://ui/title_menu.tscn"
@export var disconnect_multiplayer = true


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.return_to_menu()
	EventService.change_menu_overlay.emit(main_menu_path)
	if disconnect_multiplayer:
		if multiplayer.is_server():
			EventService.clear_level_root()
		MultiplayerManager.remove_multiplayer_peer()

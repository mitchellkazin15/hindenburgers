class_name OverlayNewMenuButton
extends Button

@export_file() var next_scene_path : String
@export var disconnect_multiplayer = false


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.change_menu_overlay.emit(next_scene_path)
	if disconnect_multiplayer:
		MultiplayerManager.remove_multiplayer_peer()

class_name OpenNewSceneButton
extends Button

@export_file() var next_scene_path : String
@export var disconnect_multiplayer = false


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	if disconnect_multiplayer:
		MultiplayerManager.remove_multiplayer_peer()
	EventService.change_scene.emit(next_scene_path)

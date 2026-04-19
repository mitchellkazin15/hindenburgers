class_name QuitGameButton
extends Button


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	SaveUtilities.save_character_and_or_level(multiplayer.get_unique_id())
	EventService.quit_game.emit()

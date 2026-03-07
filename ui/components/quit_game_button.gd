class_name QuitGameButton
extends Button


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.quit_game.emit()

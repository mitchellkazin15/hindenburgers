class_name SaveGameButton
extends Button


func _ready():
	button_down.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.save_game.emit()

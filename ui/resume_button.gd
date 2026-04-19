class_name ResumeButton
extends Button


func _ready():
	button_down.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.handle_in_game_menu_change()

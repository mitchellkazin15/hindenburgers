class_name ChangePauseStateButton
extends Button


func _ready():
	button_down.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.change_pause_state.emit()

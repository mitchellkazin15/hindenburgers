class_name RestartButton
extends Button


func _ready():
	button_down.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.change_pause_state.emit()
	EventService.start_game.emit(EventService.game_type, EventService.game_info)

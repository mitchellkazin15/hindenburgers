class_name ContinueGameButton
extends Button


func _ready():
	button_down.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.change_pause_state.emit()
	EventService.start_game.emit(EventService.GAME_TYPE.CONTINUE_POOL, {})

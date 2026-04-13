class_name SettingsMenuButton
extends Button


func _ready() -> void:
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	EventService.change_settings_overlay_state.emit(true)

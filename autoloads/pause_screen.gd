extends CanvasLayer

@onready var pause_menu : PauseMenu = $PauseMenu

var displayed = false


func _ready():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	hide()


func pause_state_changed():
	if displayed:
		hide_menu()
		return
	display_menu()


func hide_menu():
	displayed = false
	hide()
	process_mode = ProcessMode.PROCESS_MODE_DISABLED


func display_menu():
	displayed = true
	show()
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	pause_menu.initial_focus.grab_focus()

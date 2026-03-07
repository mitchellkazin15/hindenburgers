class_name MenuTabButton
extends Button

@onready var menu : Control = $Menu


func _ready():
	button_down.connect(_on_button_pressed)
	if has_focus():
		menu.show()
	else:
		menu.hide()


func _on_button_pressed():
	_hide_other_tab_menus()
	menu.show()


func _hide_other_tab_menus():
	for child in get_parent().get_children():
		if child != self and child is MenuTabButton:
			child.menu.hide()

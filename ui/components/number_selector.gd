class_name NumberSelector
extends Button

signal values_updated

@export var label : String
@export var min : int
@export var max : int
@export var default : int
var value
var selected


func _ready():
	selected = false
	value = default
	text = "%s: %d" % [label, value]
	button_down.connect(_on_button_pressed)
	values_updated.connect(_on_values_updated)


func _on_button_pressed():
	selected = not selected
	grab_focus()
	set_focus_mode(Control.FOCUS_ALL)


func _input(event):
	if not selected:
		return
	if event.is_action_pressed("ui_up"):
		value += 1
		if value > max:
			value = min
		accept_event()
	if event.is_action_pressed("ui_down"):
		value -= 1
		if value < min:
			value = max
		accept_event()
	text = "%s: %d" % [label, value]


func _on_values_updated():
	text = "%s: %d" % [label, value]

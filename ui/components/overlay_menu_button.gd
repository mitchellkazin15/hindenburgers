class_name OverlayMenuButton
extends Button

@export_file() var overlay_menu_path : String
@export var return_focus : Control


func _ready():
	button_down.connect(_on_button_pressed)


func _on_button_pressed():
	var overlay_menu = load(overlay_menu_path).instantiate()
	get_tree().root.add_child(overlay_menu)
	overlay_menu.return_focus = return_focus

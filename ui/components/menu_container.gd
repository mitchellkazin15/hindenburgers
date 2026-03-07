class_name MenuContainer
extends Control

@export_file() var first_menu_path : String


func _ready() -> void:
	replace_menu(first_menu_path)


func replace_menu(menu_path):
	for child in get_children():
		child.queue_free()
	var new_menu = load(menu_path).instantiate()
	add_child(new_menu)

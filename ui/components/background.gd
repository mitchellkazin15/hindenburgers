class_name Background
extends TextureRect


func _ready():
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	call_deferred("_on_viewport_size_changed")


func _on_viewport_size_changed():
	scale.x = 1
	scale.y = 1
	size.x = get_viewport().size.x
	size.y = get_viewport().size.y

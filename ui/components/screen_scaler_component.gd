class_name ScreenScalerComponent
extends Node

## Always keep parent's x scale matched with viewport's x, else preserve y scale
@export var preserve_y = true
@export var base_viewport_size = Vector2(1920.0, 1080.0)
@export_range(0.0, 1.0) var pivot_offset_x = 0.5
@export_range(0.0, 1.0) var pivot_offset_y = 0.5

var parent : CanvasItem
var initial_scale : Vector2


func _ready() -> void:
	parent = get_parent()
	initial_scale = parent.scale
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	call_deferred("_on_viewport_size_changed")


func _on_viewport_size_changed() -> void:
	if parent is Control:
		parent.pivot_offset.x = parent.size.x * pivot_offset_x
		parent.pivot_offset.y = parent.size.y * pivot_offset_y
		
	var scalar : float
	if preserve_y:
		scalar = get_viewport().size.y / base_viewport_size.y
	else:
		scalar = get_viewport().size.x / base_viewport_size.x
	parent.scale = initial_scale * scalar

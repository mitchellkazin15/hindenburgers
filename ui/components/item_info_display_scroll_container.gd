class_name ItemInfoDisplayScrollContainer
extends ScrollContainer

@onready var vbox : VBoxContainer = $VBoxContainer

@export var item_info_display_area : Area2D
@export var item_display_scene : PackedScene


func _ready() -> void:
	assert(item_display_scene.instantiate() is ItemInfoDisplay)
	vbox.minimum_size_changed.connect(_on_min_size_changed)
	_on_min_size_changed()
	clear_container()
	if not item_info_display_area and TreeUtilities.has_parent_of_name("PoolHud", self):
		item_info_display_area = TreeUtilities.get_parent_of_name("PoolHud", self).item_info_display_area
	item_info_display_area.area_entered.connect(_on_area_change)
	item_info_display_area.area_exited.connect(_on_area_change)


func _on_min_size_changed():
	size.x = vbox.get_minimum_size().x * 1.1


func _on_area_change(_area):
	display_item_display()


func clear_container():
	for child in vbox.get_children():
		child.queue_free()


func display_item_display():
	clear_container()
	for area in item_info_display_area.get_overlapping_areas():
		if not area.get_parent() is Item or not area.get_parent().has_node("ItemInfo"):
			continue
		var item : Item = area.get_parent()
		var info : ItemInfo = item.get_node("ItemInfo")
		var item_display : ItemInfoDisplay = item_display_scene.instantiate()
		item_display.item_sprite.texture = item.get_node("Sprite2D").texture
		item_display.item_sprite.material = item.get_node("Sprite2D").material
		item_display.item_name.text = info.display_name
		item_display.item_description.text = info.desription
		vbox.add_child(item_display)
		if item_display.item_sprite.texture.get_size() > Vector2(64.0, 64.0):
			item_display.item_sprite.scale = Vector2(64.0, 64.0) / item_display.item_sprite.texture.get_size()


func _physics_process(delta: float) -> void:
	if item_info_display_area.get_overlapping_areas().size() == 0:
		clear_container()

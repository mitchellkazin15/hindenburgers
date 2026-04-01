class_name VendingMachine
extends StaticBody3D

@export var item : PackedScene
@export var price = 1.0
@export var dispense_pos : Node3D
@export var label : Label3D


func _ready() -> void:
	var item_name = item.resource_path.split("/")[-1].remove_chars(".tscn")
	print(item.resource_path)
	print(item.resource_path.split("/"))
	print(item.resource_path.split("/")[-1])
	label.text = "%s $%.2f" % [item_name, price]


func dispense_item():
	if not is_multiplayer_authority():
		return
	var item_node = item.instantiate()
	var parent_node = $/root/MultiplayerBaseScene/LevelRoot
	parent_node.add_child(item_node, true)
	item_node.top_level = true
	item_node.position = dispense_pos.global_position
	if item_node is RigidBody3D:
		item_node.apply_central_impulse(5.0 * global_basis.z * item_node.mass)

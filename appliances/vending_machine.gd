class_name VendingMachine
extends StaticBody3D

@export var item : PackedScene
@export var price = 1.0
@export var dispense_pos : Node3D
@export var label : Label3D


func _ready() -> void:
	var item_name = item.resource_path.split("/")[-1].trim_suffix(".tscn")
	label.text = "%s $%.2f" % [item_name, price]


func dispense_item():
	if not is_multiplayer_authority():
		return
	var item_node = item.instantiate()
	MultiplayerManager.add_node_to_spawner(item_node, dispense_pos.global_position)
	if item_node is RelativeRigidBody3D:
		item_node.apply_relative_central_impulse(5.0 * global_basis.z * item_node.mass)

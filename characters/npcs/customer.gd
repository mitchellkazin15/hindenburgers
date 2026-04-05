class_name Customer
extends RigidBody3D

@export var eat_list_override : Array[String]
@export var payment : PackedScene

func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	if eat_list_override and eat_list_override.size() > 0:
		$SuckArea3D.eat_list = eat_list_override
	if payment:
		$Cloaca.poop_scene = payment

class_name HoldableItem
extends RelativeRigidBody3D

signal use_finished

@export var unlock_rotation_on_use = false
@export var max_use_charge_time = 1.0

var item_holder : Character
var being_held = false
var old_collision_child : CollisionShape3D


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())


func set_being_held(holder : Character):
	being_held = true
	freeze = true
	old_collision_child = $CollisionShape3D
	remove_child(old_collision_child)
	item_holder = holder


@rpc("any_peer", "call_local", "reliable")
func release():
	being_held = false
	add_child(old_collision_child)
	freeze = false


## Meant to be overridden
func start_use():
	pass


## Meant to be overridden
func use(use_charge_time : float):
	pass

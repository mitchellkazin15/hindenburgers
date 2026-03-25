class_name HoldableItem
extends RigidBody3D

signal use_finished

@export var unlock_rotation_on_use = false

var item_holder : Character
var being_held = false


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())


func set_being_held(holder : Character):
	being_held = true
	freeze = true
	item_holder = holder


@rpc("any_peer", "call_local", "reliable")
func release():
	being_held = false
	freeze = false


## Meant to be overridden
func use():
	pass

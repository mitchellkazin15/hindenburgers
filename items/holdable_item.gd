class_name HoldableItem
extends RigidBody3D

var being_held = false


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())


func set_being_held():
	being_held = true
	freeze = true


@rpc("any_peer", "call_local", "reliable")
func release():
	being_held = false
	freeze = false


func use():
	pass

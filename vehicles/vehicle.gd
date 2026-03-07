class_name Vehicle
extends RigidBody3D


@export var being_driven = false
@export var driver : Character
@export var driver_seat : RemoteTransform3D
@export var camera : Camera3D
@export var synchronizer : MultiplayerSynchronizer


func set_driver(driving_character: Character) -> void:
	being_driven = true
	driver = driving_character
	driver_seat.remote_path = driver.get_path()
	driver.locked_interaction_ended.connect(_on_end_locked_interaction)
	camera.set_process(true)
	camera.set_process_input(true)
	camera.current = true
	call_deferred("_unfreeze")


@rpc("any_peer", "call_local", "reliable")
func update_authority(new_authority: int) -> void:
	print("current authority: ",  get_multiplayer_authority())
	print("setting new authority: ", new_authority)
	set_multiplayer_authority(new_authority, true)
	set_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())


func _on_end_locked_interaction() -> void:
	being_driven = false
	camera.current = false
	driver_seat.remote_path = NodePath("")
	driver.locked_interaction_ended.disconnect(_on_end_locked_interaction)
	driver = null


func _unfreeze() -> void:
	freeze = false

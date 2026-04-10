class_name Vehicle
extends RelativeRigidBody3D


@export var being_driven = false
@export var driver : Character
@export var driver_seat : RemoteTransform3D
@export var camera : Camera3D
@export var synchronizer : MultiplayerSynchronizer
@export var vehicle_controller : VehiclePlayerInputController


func _ready() -> void:
	super._ready()
	camera.current = false
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())


func set_driver(driving_character: Character) -> bool:
	if being_driven:
		return false
	being_driven = true
	driver = driving_character
	driver.locked_interaction_ended.connect(_on_end_locked_interaction)
	call_deferred("_unfreeze")
	print(" new driver: ", driver.input_controller.get_multiplayer_authority(), " set by: ", get_multiplayer_authority())
	update_authority.rpc(driver.input_controller.get_multiplayer_authority())
	update_driving_status.rpc(being_driven, str(driver.get_path()))
	return true


@rpc("any_peer", "call_local", "reliable")
func update_driving_status(being_driven: bool, driver_path : String) -> void:
	driver_seat.remote_path = NodePath(driver_path)
	self.being_driven = being_driven


@rpc("any_peer", "call_local", "reliable")
func update_authority(new_authority: int) -> void:
	print("current authority: ",  get_multiplayer_authority())
	print("setting new authority: ", new_authority)
	if camera:
		camera.set_multiplayer_authority(new_authority)
		camera.set_process(camera.is_multiplayer_authority())
		camera.set_process_input(camera.is_multiplayer_authority())
		camera.current = camera.is_multiplayer_authority()
	vehicle_controller.set_multiplayer_authority(new_authority)
	vehicle_controller.set_process(vehicle_controller.is_multiplayer_authority())
	vehicle_controller.set_process_input(vehicle_controller.is_multiplayer_authority())


func _on_end_locked_interaction() -> void:
	being_driven = false
	if camera:
		camera.current = false
	driver.locked_interaction_ended.disconnect(_on_end_locked_interaction)
	driver = null
	update_driving_status.rpc(being_driven, "")


func _unfreeze() -> void:
	freeze = false

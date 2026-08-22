class_name HoldableItem
extends RelativeRigidBody3D

signal use_finished

@export var unlock_rotation_on_use = false
@export var max_use_charge_time = 1.0
@export var being_held = false

var item_holder : Character
var prev_item_holder : Character
var prev_release_position : Vector3
var old_collision_child : CollisionShape3D


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	super._ready()


func set_being_held(holder : Character):
	being_held = true
	freeze = true
	old_collision_child = $CollisionShape3D
	remove_child(old_collision_child)
	item_holder = holder
	prev_item_holder = item_holder


func release():
	if item_holder:
		prev_release_position = item_holder.global_position
	item_holder = null
	being_held = false
	add_child(old_collision_child)
	freeze = false


## Meant to be overridden
func start_use():
	pass


## Meant to be overridden
func use(use_charge_time : float):
	pass


## Smoothly swings the item [param angle] radians about its own X axis, in global
## space, so the swing direction is the same no matter how the holder is oriented
## (upright, sideways, or on the underside of a planet).
## Interpolates with quaternion slerp rather than Euler angles, so it can never
## take the long way round at a wrap boundary. Returns the Tween so callers can
## connect to [signal Tween.finished].
func swing_about_local_x(angle : float, duration : float) -> Tween:
	var start_quat := global_basis.orthonormalized().get_rotation_quaternion()
	var end_basis := global_basis.rotated(global_basis.x.normalized(), angle)
	var end_quat := end_basis.orthonormalized().get_rotation_quaternion()
	var tween := get_tree().create_tween()
	tween.tween_method(
		func(t : float): global_basis = Basis(start_quat.slerp(end_quat, t)),
		0.0, 1.0, duration)
	return tween

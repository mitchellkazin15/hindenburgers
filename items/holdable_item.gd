class_name HoldableItem
extends RelativeRigidBody3D

signal use_finished

@export var unlock_rotation_on_use = false
@export var max_use_charge_time = 1.0
@export var being_held = false
@export var reset_rotation_when_grabbed = true
@export var hold_offset = Vector3.ZERO

var item_holder : Character
var prev_item_holder : Character
var prev_release_position : Vector3
var old_collision_children : Array[CollisionShape3D] = []


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	for child in get_children():
		if child is CollisionShape3D:
			old_collision_children.append(child)
	super._ready()


func set_being_held(holder : Character):
	being_held = true
	freeze = true
	for child in old_collision_children:
		remove_child(child)
	item_holder = holder
	prev_item_holder = item_holder
	for effect in get_effects():
		effect.on_held(holder)


func release():
	for effect in get_effects():
		effect.on_released()
	if item_holder:
		prev_release_position = item_holder.global_position
	item_holder = null
	being_held = false
	for child in old_collision_children:
		add_child(child)
	freeze = false


func start_use():
	for effect in get_effects():
		effect.start_effect(item_holder)


func use(use_charge_time : float):
	apply_effects(item_holder, use_charge_time)


func apply_effects(user : Node3D, use_charge_time : float = INF) -> bool:
	var effects := get_effects()
	for effect in effects:
		if not effect.can_apply(user, use_charge_time):
			return false
	for effect in effects:
		effect.apply_effect(user, use_charge_time)
	return true


func get_effects() -> Array[ItemEffect]:
	var effects : Array[ItemEffect] = []
	for child in get_children():
		if child is ItemEffect:
			effects.append(child)
	return effects


func has_effect(effect_type : Script) -> bool:
	for effect in get_effects():
		if is_instance_of(effect, effect_type):
			return true
	return false


func swing_about_local_x(angle : float, duration : float) -> Tween:
	return swing_about_local_axis(Vector3.RIGHT, angle, duration)


func swing_about_local_axis(local_axis : Vector3, angle : float, duration : float) -> Tween:
	var start_quat := global_basis.orthonormalized().get_rotation_quaternion()
	var end_basis := global_basis.rotated((global_basis * local_axis).normalized(), angle)
	var end_quat := end_basis.orthonormalized().get_rotation_quaternion()
	var tween := get_tree().create_tween()
	tween.tween_method(
		func(t : float): global_basis = Basis(start_quat.slerp(end_quat, t)),
		0.0, 1.0, duration)
	return tween

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
## Swings currently being combined, see swing_about_local_axis
var _swings : Array[Dictionary] = []
var _swing_start_basis : Basis
## Effects still running from the last use, see begin_use_action
var _pending_use_actions := 0


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
	# Nothing is still running (e.g. no swing applied), so the use is already over
	if _pending_use_actions == 0:
		use_finished.emit()


## Effects are grouped by the item they came from (see ItemEffect.source_index).
## A group only applies if all of its effects can, but groups don't block each other,
## so in a stack a bun that needs a full charge to eat doesn't stop a spatula flip.
## Returns true if any group applied.
func apply_effects(user : Node3D, use_charge_time : float = INF) -> bool:
	var groups := {}
	for effect in get_effects():
		if not groups.has(effect.source_index):
			groups[effect.source_index] = []
		groups[effect.source_index].append(effect)
	var applied_any = false
	for group in groups.values():
		if not group.all(func(effect): return effect.can_apply(user, use_charge_time)):
			continue
		for effect in group:
			effect.apply_effect(user, use_charge_time)
		applied_any = true
	return applied_any


func get_effects() -> Array[ItemEffect]:
	var effects : Array[ItemEffect] = []
	for child in get_children():
		if child is ItemEffect:
			effects.append(child)
	return effects


## State recorded when this item is added to a stack (e.g. cook_state).
## Children that define get_item_state() contribute their keys.
func get_item_state() -> Dictionary:
	var state := {}
	for child in get_children():
		if child.has_method("get_item_state"):
			state.merge(child.get_item_state())
	return state


func has_effect(effect_type : Script) -> bool:
	for effect in get_effects():
		if is_instance_of(effect, effect_type):
			return true
	return false


func swing_about_local_x(angle : float, duration : float) -> Tween:
	return swing_about_local_axis(Vector3.RIGHT, angle, duration)


## Swings that overlap in time (e.g. several SwingEffects on one stack) are combined,
## each rotating about its own local axis, instead of the last tween to run winning.
func swing_about_local_axis(local_axis : Vector3, angle : float, duration : float) -> Tween:
	if _swings.all(func(swing): return swing.done):
		_swings.clear()
		_swing_start_basis = global_basis.orthonormalized()
	var swing := {axis = local_axis.normalized(), angle = angle, progress = 0.0, done = false}
	_swings.append(swing)
	var tween := create_tween()
	tween.tween_method(_set_swing_progress.bind(swing), 0.0, 1.0, duration)
	tween.finished.connect(func(): swing.done = true)
	return tween


func _set_swing_progress(progress : float, swing : Dictionary):
	swing.progress = progress
	var swing_basis := _swing_start_basis
	for active_swing in _swings:
		swing_basis = swing_basis * Basis(active_swing.axis, active_swing.angle * active_swing.progress)
	global_basis = swing_basis


## Effects that take time to finish a use call this when they start and
## end_use_action when they're done, so use_finished fires once for the whole use.
func begin_use_action():
	_pending_use_actions += 1


## Returns true if this was the last pending action, i.e. the use is finished
func end_use_action() -> bool:
	_pending_use_actions = max(0, _pending_use_actions - 1)
	return _pending_use_actions == 0

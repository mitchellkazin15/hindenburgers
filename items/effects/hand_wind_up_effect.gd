class_name HandWindUpEffect
extends ItemEffect

@export var wind_up_rotation = Vector3(0.0, 0.0, -PI / 2.0)
@export var wind_up_position_offset = Vector3.ZERO
## Reset position/rotation on use_finished, otherwise reset on normal use
@export var reset_on_use_finished = true

var start_use_tween : Tween
## How far into the wind up the hand is, 0 = resting, 1 = fully wound up
var _weight := 0.0
var _holder : Character


func _init() -> void:
	requires_full_charge = false


func _ready() -> void:
	if reset_on_use_finished:
		item.use_finished.connect(_reset_transform)


func on_reparent():
	if reset_on_use_finished:
		item.use_finished.connect(_reset_transform)


## Wind ups are layered onto the hand as offsets (see Character.set_hand_offset),
## so several wind up effects on one stack add together instead of fighting over the hand.
func start_effect(holder : Character):
	_holder = holder
	if start_use_tween:
		start_use_tween.kill()
	start_use_tween = create_tween()
	start_use_tween.tween_method(_set_weight, _weight, 1.0, item.max_use_charge_time)


func apply_effect(_user : Node3D, _use_charge_time : float):
	if start_use_tween:
		start_use_tween.stop()
	if not reset_on_use_finished:
		_reset_transform()


func on_released():
	if start_use_tween:
		start_use_tween.kill()
	_weight = 0.0
	_holder = null


func _set_weight(weight : float):
	_weight = weight
	if _holder and item.being_held:
		_holder.set_hand_offset(self, weight * wind_up_position_offset, weight * wind_up_rotation)


func _reset_transform():
	_weight = 0.0
	if _holder and item.being_held:
		_holder.clear_hand_offset(self)

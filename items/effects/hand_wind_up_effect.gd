class_name HandWindUpEffect
extends ItemEffect

@export var wind_up_rotation = Vector3(0.0, 0.0, -PI / 2.0)
@export var wind_up_position_offset = Vector3.ZERO
## Reset position/rotation on use_finished, otherwise reset on normal use
@export var reset_on_use_finished = true

var start_use_tween : Tween


func _init() -> void:
	requires_full_charge = false


func _ready() -> void:
	if reset_on_use_finished:
		item.use_finished.connect(_reset_transform)


func on_reparent():
	if reset_on_use_finished:
		item.use_finished.connect(_reset_transform)


func start_effect(holder : Character):
	start_use_tween = get_tree().create_tween()
	start_use_tween.set_parallel(true)
	start_use_tween.tween_property(holder.hand, "rotation", holder.hand.rotation + wind_up_rotation, item.max_use_charge_time)
	start_use_tween.tween_property(holder.hand, "position", holder.hand.position + wind_up_position_offset, item.max_use_charge_time)
	


func apply_effect(_user : Node3D, _use_charge_time : float):
	if not reset_on_use_finished:
		_reset_transform()
	if start_use_tween:
		start_use_tween.stop()


func _reset_transform():
	if item.being_held:
		item.item_holder.hand.rotation = Vector3.ZERO
		item.item_holder.hand.position = item.item_holder.base_hand_pos + item.hold_offset

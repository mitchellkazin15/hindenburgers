class_name HandWindUpEffect
extends ItemEffect

@export var wind_up_rotation = Vector3(0.0, 0.0, -PI / 2.0)

var start_use_tween : Tween


func _init() -> void:
	requires_full_charge = false


func _ready() -> void:
	item.use_finished.connect(_on_use_finished)


func start_effect(holder : Character):
	start_use_tween = get_tree().create_tween()
	start_use_tween.tween_property(holder.hand, "rotation", holder.hand.rotation + wind_up_rotation, item.max_use_charge_time)


func apply_effect(_user : Node3D, _use_charge_time : float):
	if start_use_tween:
		start_use_tween.stop()


func _on_use_finished():
	if item.being_held:
		item.item_holder.hand.rotation = Vector3.ZERO

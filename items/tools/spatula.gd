class_name Spatula
extends HoldableItem

@export var per_sec_use_strength = 10.0

var prev_grav_scale


func use(use_charge_time : float):
	if not is_multiplayer_authority():
		return
	freeze = false
	if gravity_scale != 0:
		prev_grav_scale = gravity_scale
	gravity_scale = 0
	self.apply_torque_impulse(-per_sec_use_strength * min(max_use_charge_time, use_charge_time) * global_basis.x)
	get_tree().create_timer(0.25).timeout.connect(_on_swing_finished)


func _on_swing_finished():
	gravity_scale = prev_grav_scale
	if being_held:
		freeze = true
	use_finished.emit()

class_name Knife
extends HoldableItem

@export var per_sec_use_strength = 1.25

var active = false
var prev_grav_scale


func use(use_charge_time : float):
	if not is_multiplayer_authority():
		return
	freeze = false
	if gravity_scale != 0:
		prev_grav_scale = gravity_scale
	gravity_scale = 0
	active = true
	self.apply_torque_impulse(per_sec_use_strength * min(max_use_charge_time, use_charge_time) * global_basis.x)
	get_tree().create_timer(0.1).timeout.connect(_on_swing_finished)


func _on_swing_finished():
	gravity_scale = prev_grav_scale
	if being_held:
		freeze = true
	active = false
	use_finished.emit()

class_name Spatula
extends HoldableItem

var prev_grav_scale


func use():
	freeze = false
	if gravity_scale != 0:
		prev_grav_scale = gravity_scale
	gravity_scale = 0
	self.apply_torque_impulse(-10.0 * global_basis.x)
	get_tree().create_timer(0.25).timeout.connect(_on_swing_finished)


func _on_swing_finished():
	gravity_scale = prev_grav_scale
	if being_held:
		freeze = true
	use_finished.emit()

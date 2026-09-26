class_name Knife
extends HoldableItem

@export var damage_area : DamageArea3D
@export var swing_duration = 0.1
@export var max_swing_angle = PI / 2.0

var prev_grav_scale


func use(use_charge_time : float):
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	freeze = false
	if gravity_scale != 0:
		prev_grav_scale = gravity_scale
	gravity_scale = 0
	damage_area.active = true
	damage_area.damage_ratio = min(use_charge_time / max_use_charge_time, 1.0)
	var tween = swing_about_local_x(max_swing_angle, swing_duration)
	tween.finished.connect(_on_swing_finished)


func _on_swing_finished():
	gravity_scale = prev_grav_scale
	if being_held:
		freeze = true
	damage_area.active = false
	use_finished.emit()

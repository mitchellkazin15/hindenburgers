class_name SwingEffect
extends ItemEffect

@export var swing_angle = PI / 2.0
@export var swing_axis = Vector3.RIGHT
@export var scale_angle_with_charge = false
@export var swing_duration = 0.1
## If 0, the swing finishes when the swing tween ends
@export var active_duration = 0.0

var prev_grav_scale


func _init() -> void:
	requires_full_charge = false


func can_apply(user : Node3D, use_charge_time : float) -> bool:
	return super.can_apply(user, use_charge_time) and MultiplayerManager.safe_is_multiplayer_authority(item)


func apply_effect(_user : Node3D, use_charge_time : float):
	item.freeze = false
	if item.gravity_scale != 0:
		prev_grav_scale = item.gravity_scale
	item.gravity_scale = 0
	var angle = swing_angle
	if scale_angle_with_charge:
		angle *= get_charge_time(use_charge_time) / item.max_use_charge_time
	var tween = item.swing_about_local_axis(swing_axis, angle, swing_duration)
	if active_duration > 0.0:
		get_tree().create_timer(active_duration).timeout.connect(_on_swing_finished)
	else:
		tween.finished.connect(_on_swing_finished)


func _on_swing_finished():
	item.gravity_scale = prev_grav_scale
	if item.being_held:
		item.freeze = true
	item.use_finished.emit()

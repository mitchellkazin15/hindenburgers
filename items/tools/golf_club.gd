class_name GolfClub
extends HoldableItem

@export var per_sec_use_strength = 5.0

var prev_grav_scale
var hit_area_active = false
var hit_strength = 0.0
var start_use_tween : Tween
var bodies_hit_per_swing = []


func _ready() -> void:
	$HitArea3D.body_entered.connect(_on_hit)


func start_use():
	start_use_tween = get_tree().create_tween()
	start_use_tween.tween_property(item_holder.hand, "rotation", item_holder.hand.rotation + Vector3(0.0, 0.0, -PI / 2.0), max_use_charge_time)


func use(use_charge_time : float):
	if not is_multiplayer_authority():
		return
	freeze = false
	if gravity_scale != 0:
		prev_grav_scale = gravity_scale
	gravity_scale = 0
	if start_use_tween:
		start_use_tween.stop()
	bodies_hit_per_swing = []
	self.apply_torque_impulse(0.1 * min(max_use_charge_time, use_charge_time) * global_basis.z)
	hit_area_active = true
	hit_strength = per_sec_use_strength * use_charge_time
	get_tree().create_timer(0.4).timeout.connect(_on_swing_finished)


func _on_swing_finished():
	gravity_scale = prev_grav_scale
	hit_area_active = false
	hit_strength = 0.0
	if being_held:
		item_holder.hand.rotation = Vector3.ZERO
		freeze = true
	use_finished.emit()


func _on_hit(body):
	if not hit_area_active:
		return
	if body is RigidBody3D and body != self and not body in bodies_hit_per_swing:
		if body is Character:
			body.launched = true
			hit_strength *= 10.0
		body.apply_central_impulse((hit_strength * global_basis.x) + (1.0 * Vector3.UP))
		bodies_hit_per_swing.append(body)

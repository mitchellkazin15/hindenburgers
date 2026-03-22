class_name GolfClub
extends HoldableItem

var prev_grav_scale
var hit_area_active = false


func _ready() -> void:
	$HitArea3D.body_entered.connect(_on_hit)


func use():
	freeze = false
	if gravity_scale != 0:
		prev_grav_scale = gravity_scale
	gravity_scale = 0
	rotation -= Vector3(0.0, 0.0, PI / 2.0)
	self.apply_torque_impulse(0.1 * global_basis.z)
	hit_area_active = true
	get_tree().create_timer(0.4).timeout.connect(_on_swing_finished)


func _on_swing_finished():
	gravity_scale = prev_grav_scale
	hit_area_active = false
	if being_held:
		freeze = true
	use_finished.emit()


func _on_hit(body):
	if not hit_area_active:
		return
	if body is RigidBody3D and body != self:
		body.apply_central_impulse((5.0 * global_basis.x) + (1.0 * Vector3.UP))

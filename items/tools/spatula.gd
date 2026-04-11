class_name Spatula
extends HoldableItem

@export var per_sec_use_strength = 3.0
@export var swing_duration = 0.25

var prev_grav_scale
var active = false
var active_strength = 0.0
var burger_flip_timer : SceneTreeTimer


func _ready() -> void:
	super._ready()
	burger_flip_timer = get_tree().create_timer(0.0)


func _physics_process(delta: float) -> void:
	#super._physics_process(delta)
	if not is_multiplayer_authority() or not active or burger_flip_timer.time_left == 0.0:
		return
	for body in $BurgerFlipArea3D.get_overlapping_bodies():
		if body is RelativeRigidBody3D and body != self and not body is CookingBody:
			body.apply_central_impulse(active_strength * Vector3.UP)
			body.apply_torque_impulse(0.1 * active_strength * self.global_basis.x)
			active = false


func use(use_charge_time : float):
	if not is_multiplayer_authority():
		return
	freeze = false
	active = true
	if gravity_scale != 0:
		prev_grav_scale = gravity_scale
	gravity_scale = 0
	var charge_time = min(max_use_charge_time, use_charge_time)
	active_strength = per_sec_use_strength * charge_time
	var tween = get_tree().create_tween()
	var final_rotation = (-PI / 2.0) * (charge_time / max_use_charge_time)
	tween.tween_property(self, "rotation", rotation + Vector3(final_rotation, 0.0, 0.0), 0.1)
	burger_flip_timer = get_tree().create_timer(swing_duration)
	burger_flip_timer.timeout.connect(_on_swing_finished)


func _on_swing_finished():
	gravity_scale = prev_grav_scale
	active = false
	if being_held:
		freeze = true
	use_finished.emit()

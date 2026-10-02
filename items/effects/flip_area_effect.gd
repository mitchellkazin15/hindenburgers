class_name FlipAreaEffect
extends ItemEffect

@export var flip_area : Area3D
@export var per_sec_use_strength = 3.0

var active = false
var active_strength = 0.0


func _init() -> void:
	requires_full_charge = false


func _ready() -> void:
	item.use_finished.connect(_on_use_finished)


func on_reparent():
	item.use_finished.connect(_on_use_finished)


func _physics_process(_delta: float) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(item) or not active:
		return
	for body in flip_area.get_overlapping_bodies():
		if body is RelativeRigidBody3D and body != item and not body is CookingBody:
			body.apply_central_impulse(active_strength * item.global_basis.y)
			body.apply_torque_impulse(0.1 * active_strength * item.global_basis.x)
			active = false


func apply_effect(_user : Node3D, use_charge_time : float):
	active = true
	active_strength = per_sec_use_strength * get_charge_time(use_charge_time)


func _on_use_finished():
	active = false

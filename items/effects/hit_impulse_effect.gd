class_name HitImpulseEffect
extends ItemEffect

@export var hit_area : Area3D
@export var per_sec_use_strength = 5.0
@export var character_strength_multiplier = 10.0

var hit_area_active = false
var hit_strength = 0.0
var bodies_hit_per_swing = []


func _init() -> void:
	requires_full_charge = false


func _ready() -> void:
	hit_area.body_entered.connect(_on_hit)
	item.use_finished.connect(_on_use_finished)


func apply_effect(_user : Node3D, use_charge_time : float):
	bodies_hit_per_swing = []
	hit_area_active = true
	hit_strength = per_sec_use_strength * get_charge_time(use_charge_time)


func _on_use_finished():
	hit_area_active = false
	hit_strength = 0.0


func _on_hit(body):
	if not hit_area_active:
		return
	if body is RelativeRigidBody3D and body != item and not body in bodies_hit_per_swing:
		if body is Character:
			body.set_launched()
			hit_strength *= character_strength_multiplier
		body.apply_relative_central_impulse((hit_strength * item.global_basis.x))
		bodies_hit_per_swing.append(body)

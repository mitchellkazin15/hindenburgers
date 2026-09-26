class_name DamageArea3D
extends Area3D

@export var damage = 0.0
@export var active = false:
	set(value):
		active = value
		if not active:
			return
		for body in get_overlapping_bodies():
			damage_body(body)

@export var damage_on_activation = true
@export var impulse_strength_on_damage = 0.0
@export var damage_ratio = 1.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	damage_body(body)


func damage_body(body):
	if (not MultiplayerManager.safe_is_multiplayer_authority(self) or 
		not active
	):
		return
	if body is RelativeRigidBody3D and impulse_strength_on_damage > 0.0:
		var rrb : RelativeRigidBody3D = body
		body.apply_impulse(damage_ratio * impulse_strength_on_damage * global_position.direction_to(body.global_position))
		if body is Character:
			body.set_launched()
	if not body or not body.has_node("HealthComponent"):
		return
	var health_component : HealthComponent = body.get_node("HealthComponent")
	health_component.apply_damage(damage_ratio * damage)

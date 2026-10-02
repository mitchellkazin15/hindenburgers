class_name DamageAreaEffect
extends ItemEffect

@export var damage_area : DamageArea3D


func _init() -> void:
	requires_full_charge = false


func _ready() -> void:
	item.use_finished.connect(_on_use_finished)


func on_reparent():
	item.use_finished.connect(_on_use_finished)


func apply_effect(_user : Node3D, use_charge_time : float):
	damage_area.active = true
	damage_area.damage_ratio = get_charge_ratio(use_charge_time)


func _on_use_finished():
	damage_area.active = false

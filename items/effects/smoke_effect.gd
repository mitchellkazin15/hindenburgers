class_name SmokeEffect
extends ItemEffect

@export var emissive_mesh : MeshInstance3D
@export var particles : GPUParticles3D
@export var emission_boost = 10.0

var material : StandardMaterial3D


func _ready() -> void:
	material = emissive_mesh.mesh.material


func apply_effect(_user : Node3D, _use_charge_time : float):
	show_smoke.rpc()


@rpc("any_peer", "call_local", "reliable")
func show_smoke():
	var tween = get_tree().create_tween()
	tween.tween_property(material, "emission_energy_multiplier", material.emission_energy_multiplier + emission_boost, 0.25)
	tween.tween_property(material, "emission_energy_multiplier", 0.0, 0.75)
	particles.restart()

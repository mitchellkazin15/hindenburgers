class_name Joint
extends Drug

var material : StandardMaterial3D


func _ready() -> void:
	material = $Node3D/WeedMesh.mesh.material


func use(use_charge_time : float):
	if use_charge_time < max_use_charge_time:
		return
	show_smoke.rpc()
	# new effects first, then call super
	super.use(use_charge_time)


@rpc("any_peer", "call_local", "reliable")
func show_smoke():
	var tween = get_tree().create_tween()
	tween.tween_property(material, "emission_energy_multiplier", material.emission_energy_multiplier + 10.0, 0.25)
	tween.tween_property(material, "emission_energy_multiplier", 0.0, 0.75)
	$Node3D/GPUParticles3D.restart()

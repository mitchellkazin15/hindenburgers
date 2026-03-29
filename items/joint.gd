class_name Joint
extends Drug

var material : StandardMaterial3D


func _ready() -> void:
	material = $Node3D/WeedMesh.mesh.material


func use():
	var tween = get_tree().create_tween()
	tween.tween_property(material, "emission_energy_multiplier", material.emission_energy_multiplier + 10.0, 0.25)
	tween.tween_property(material, "emission_energy_multiplier", 0.0, 0.75)
	$Node3D/GPUParticles3D.restart()
	# new effects first, then call super
	super.use()

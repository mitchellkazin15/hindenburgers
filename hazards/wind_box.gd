class_name WindBox
extends Area3D

@export var wind_force = 0.0


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	$GPUParticles3D.amount *= scale.z


func _physics_process(delta: float) -> void:
	if not get_overlapping_bodies():
		return
	for body in get_overlapping_bodies():
		if body is RelativeRigidBody3D:
			body.apply_central_force(wind_force * global_basis.z)

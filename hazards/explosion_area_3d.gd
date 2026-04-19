class_name ExplosionArea3D
extends Area3D


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())


func explode(power):
	for body in get_overlapping_bodies():
		if body is Character:
			body.set_launched()
		if body is RelativeRigidBody3D:
			body.apply_relative_central_impulse(power * (global_position.direction_to(body.global_position)))

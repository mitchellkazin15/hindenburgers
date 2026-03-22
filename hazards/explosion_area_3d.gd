class_name ExplosionArea3D
extends Area3D


func explode(power):
	for body in get_overlapping_bodies():
		if body is Character:
			body.launched = true
		if body is RigidBody3D:
			body.apply_central_impulse(power * (global_position.direction_to(body.global_position)))

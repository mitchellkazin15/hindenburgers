class_name ExplosionArea3D
extends Area3D


func explode(power):
	print("trying explode")
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			print("explode _on ", body)
			body.apply_central_impulse(power * (global_position.direction_to(body.global_position)))

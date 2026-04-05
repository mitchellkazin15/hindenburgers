class_name ReferenceFrameArea3D
extends Area3D

@export var reference_body : RigidBody3D


#func _ready() -> void:
	#body_exited.connect()


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is HoldableItem and not body.being_held:
			pass
			#body.set_new_reference_frame(reference_body.linear_velocity)
			#var target_vel = reference_body.linear_velocity - body.linear_velocity
			#target_vel.y = 0.0
			#body.apply_central_impulse(body.mass * target_vel)


#func _on_body_exited(body):
	#pass

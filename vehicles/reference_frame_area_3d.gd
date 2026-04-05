class_name ReferenceFrameArea3D
extends Area3D

@export var reference_body : RigidBody3D


func _ready() -> void:
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RelativeRigidBody3D and body != reference_body and not body.freeze:
			body.set_new_reference_frame(reference_body.linear_velocity)
		if body is StaticBody3D:
			body.constant_linear_velocity = reference_body.linear_velocity


func _on_body_exited(body):
	if body is RelativeRigidBody3D:
		body.set_new_reference_frame(Vector3.ZERO, false)
	if body is Character:
		body.launched = true

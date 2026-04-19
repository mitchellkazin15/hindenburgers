class_name ReferenceFrameArea3D
extends Area3D

@export var reference_body : RigidBody3D


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	if MultiplayerManager.safe_is_multiplayer_authority(self):
		body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RelativeRigidBody3D and body != reference_body:
			body.set_new_reference_frame(reference_body.linear_velocity)
		if body is StaticBody3D:
			body.constant_linear_velocity = reference_body.linear_velocity


func _on_body_exited(body):
	if body is RelativeRigidBody3D:
		body.set_new_reference_frame(Vector3.ZERO, false)
	if body is Character:
		body.set_launched()

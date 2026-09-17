class_name CameraPivot
extends Node3D

@export var follow_body : RelativeRigidBody3D

var orignal_offset : Vector3


func _ready() -> void:
	top_level = true
	orignal_offset = global_position - follow_body.global_position


func _physics_process(delta: float) -> void:
	var forward = -global_basis.z
	basis = Basis.looking_at(forward, follow_body.world_up)
	global_position = follow_body.global_position + orignal_offset.length() * follow_body.world_up

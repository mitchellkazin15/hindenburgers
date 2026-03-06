class_name CameraPivot
extends Node3D

@export var rotation_invariant = true


func _process(delta: float) -> void:
	if rotation_invariant:
		global_rotation = Vector3.ZERO

class_name StayOnVehicleArea3D
extends Area3D

@export var rigid_body : RigidBody3D

var prev_relative_vel = Vector3.ZERO
#
#
#func _ready() -> void:
	#if not rigid_body and get_parent() is RelativeRigidBody3D:
		#rigid_body = get_parent()
#
#
#func _physics_process(delta: float) -> void:
	#for body in get_overlapping_bodies():
		#if body is Vehicle:
			#prev_relative_vel = body.linear_velocity
			#rigid_body.apply_relative_central_impulse(rigid_body.linear_velocity - prev_relative_vel)

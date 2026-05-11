class_name PlanetGravityArea3D
extends Area3D

@export var gravitational_acceleration = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if not body is RelativeRigidBody3D:
		return
	var rrb : RelativeRigidBody3D = body
	rrb.gravity_scale = 0.0
	#if rrb is Character:
		#rrb.lock_rotation = false


func _on_body_exited(body):
	if not body is RelativeRigidBody3D:
		return
	var rrb : RelativeRigidBody3D = body
	rrb.gravity_scale = rrb.original_gravity_scale
	#if rrb is Character:
		#rrb.lock_rotation = true


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if not body is RelativeRigidBody3D:
			continue
		var rrb : RelativeRigidBody3D = body
		var central_dir = rrb.global_position.direction_to(self.global_position)
		rrb.apply_central_force(gravitational_acceleration * rrb.mass * rrb.original_gravity_scale * central_dir)
		if rrb is Character:
			var target_up = -central_dir
			var rot = Quaternion(global_basis.y.normalized(), target_up)
			rrb.global_basis = Basis(rot) * global_basis

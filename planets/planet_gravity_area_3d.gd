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
			var character : Character = rrb
			var target_up = -central_dir
			var forward = -character.global_basis.z

			# Strip the component of forward along target_up so it lies in
			# the tangent plane.
			forward = forward - target_up * forward.dot(target_up)

			# If that collapses (character was facing exactly along target_up),
			# pick any tangent direction as fallback.
			if forward.length_squared() < 0.0001:
				forward = character.global_basis.x.cross(target_up)

			forward = forward.normalized()
			character.look_at(character.global_position + forward, target_up)
		#if rrb is Character:
			#var character : Character = rrb
			#var target_up = -central_dir
			#var forward = -character.global_basis.z
			#if forward.length_squared() < 0.0001:
				#forward = character.global_basis.x.cross(target_up)
				#forward = forward.normalized()
			#if absf(forward.dot(target_up)) < 0.9999:
				#character.look_at(character.global_position + forward, target_up)
			#var rot = Quaternion(global_basis.y.normalized(), target_up)
			#rrb.global_basis = Basis(rot) * global_basis

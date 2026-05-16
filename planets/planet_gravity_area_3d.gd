class_name PlanetGravityArea3D
extends Area3D

@export var gravitational_acceleration = 0.0
@export var orient_speed = 20.0


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

			# What look_at would set the basis to, packaged as a value rather than applied.
			var target_basis = Basis.looking_at(forward, target_up)

			# Frame-rate-independent exponential approach. orient_speed ~ 5–10 feels good;
			# higher = snappier. With this form, the character covers (1 - 1/e) ≈ 63%
			# of the remaining error in 1/orient_speed seconds.
			var t = 1.0 - exp(-orient_speed * delta)
			character.global_basis = character.global_basis.slerp(target_basis, t)

			#forward = forward.normalized()
			#character.look_at(character.global_position + forward, target_up)

class_name PlanetGravityArea3D
extends Area3D

@export var gravitational_acceleration = 0.0
@export var orient_speed = 20.0

## Measured from the sphere shape at startup. Bodies find their source by
## distance instead of by overlap, since clients have no collision shapes.
var influence_radius_squared := 0.0


func _ready() -> void:
	add_to_group(RelativeRigidBody3D.GRAVITY_SOURCE_GROUP)
	influence_radius_squared = _measure_influence_radius_squared()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _measure_influence_radius_squared() -> float:
	var largest := 0.0
	for child in get_children():
		if not child is CollisionShape3D:
			continue
		var shape = (child as CollisionShape3D).shape
		if not shape is SphereShape3D:
			continue
		var scale_vec := (child as CollisionShape3D).global_basis.get_scale()
		var scale_factor := maxf(maxf(absf(scale_vec.x), absf(scale_vec.y)), absf(scale_vec.z))
		largest = maxf(largest, (shape as SphereShape3D).radius * scale_factor)
	if largest <= 0.0:
		push_warning("PlanetGravityArea3D at %s has no SphereShape3D; bodies can't find it." % [get_path()])
	return largest * largest


func _on_body_entered(body):
	if not body is RelativeRigidBody3D:
		return
	var rrb : RelativeRigidBody3D = body
	rrb.gravity_scale = 0.0
	rrb.planet_gravity_accel = gravitational_acceleration


func _on_body_exited(body):
	if not body is RelativeRigidBody3D:
		return
	var rrb : RelativeRigidBody3D = body
	rrb.gravity_scale = rrb.original_gravity_scale
	rrb.planet_gravity_accel = 0.0
	rrb.update_world_up()
	if rrb is Character:
		var character : Character = rrb
		character.tween_basis(Basis.IDENTITY)


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if not body is RelativeRigidBody3D:
			continue
		var rrb : RelativeRigidBody3D = body
		var central_dir = rrb.global_position.direction_to(self.global_position)
		rrb.apply_central_force(gravitational_acceleration * rrb.mass * rrb.original_gravity_scale * central_dir)
		# Same value the body derives itself; one code path, no disagreement.
		rrb.update_world_up()
		if not rrb is Character:
			continue
		var character : Character = rrb
		# A dead character is meant to stay tipped over.
		if character.is_dead:
			continue
		var target_up = character.world_up
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

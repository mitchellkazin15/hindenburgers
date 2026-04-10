class_name RelativeRigidBody3D
extends RigidBody3D

var reference_frame_vel = Vector3.ZERO


func _ready() -> void:
	set_physics_process(true)
	if not is_multiplayer_authority():
		custom_integrator = true
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC


func set_new_reference_frame(frame_vel : Vector3, apply_impulse = true):
	var diff = frame_vel - reference_frame_vel
	if apply_impulse:
		super.apply_central_impulse(self.mass * diff)
	reference_frame_vel = frame_vel


func apply_relative_central_impulse(impulse : Vector3, relative_multiplier = Vector3.ONE):
	super.apply_central_impulse(impulse + mass * reference_frame_vel * relative_multiplier)


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		return
	global_position += linear_velocity * delta

class_name RelativeRigidBody3D
extends RigidBody3D

var reference_frame_vel = Vector3.ZERO


func _ready() -> void:
	if has_node("MultiplayerSynchronizer"):
		var sync : MultiplayerSynchronizer = get_node("MultiplayerSynchronizer")
		sync.replication_interval = 1.0 / Engine.physics_ticks_per_second
	if not is_multiplayer_authority():
		custom_integrator = true
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	reset_physics_interpolation()


func set_new_reference_frame(frame_vel : Vector3, apply_impulse = true):
	var diff = frame_vel - reference_frame_vel
	if apply_impulse:
		super.apply_central_impulse(self.mass * diff)
	reference_frame_vel = frame_vel


func apply_relative_central_impulse(impulse : Vector3, relative_multiplier = Vector3.ONE):
	super.apply_central_impulse(impulse + mass * reference_frame_vel * relative_multiplier)

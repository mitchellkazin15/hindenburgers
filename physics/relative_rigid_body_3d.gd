class_name RelativeRigidBody3D
extends RigidBody3D

@export var max_interpolation_steps = 100

var reference_frame_vel = Vector3.ZERO

var _last_synced_position : Vector3 = Vector3.ZERO
var _last_synced_rotation : Vector3 = Vector3.ZERO

var just_spawned = true


func _ready() -> void:
	if has_node("MultiplayerSynchronizer"):
		var sync : MultiplayerSynchronizer = get_node("MultiplayerSynchronizer")
		sync.replication_interval = 1.0 / Engine.physics_ticks_per_second
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		gravity_scale = 0.0
		for child in get_children():
			if child is CollisionShape3D:
				remove_child(child)
		custom_integrator = true
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	#reset_physics_interpolation()
	set_physics_process(is_multiplayer_authority())
	if MultiplayerManager.safe_is_server():
		RigidBodySyncManager.tracked_bodies.append(self)


func set_new_reference_frame(frame_vel : Vector3, apply_impulse = true):
	var diff = frame_vel - reference_frame_vel
	if apply_impulse:
		super.apply_central_impulse(self.mass * diff)
	reference_frame_vel = frame_vel


func apply_relative_central_impulse(impulse : Vector3, relative_multiplier = Vector3.ONE):
	super.apply_central_impulse(impulse + mass * reference_frame_vel * relative_multiplier)

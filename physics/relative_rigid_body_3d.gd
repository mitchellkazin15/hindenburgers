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
	if not is_multiplayer_authority():
		gravity_scale = 0.0
		for child in get_children():
			if child is CollisionShape3D:
				remove_child(child)
		custom_integrator = true
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	#reset_physics_interpolation()
	set_physics_process(is_multiplayer_authority())
	if multiplayer.is_server():
		RigidBodySyncManager.tracked_bodies.append(self)


func set_new_reference_frame(frame_vel : Vector3, apply_impulse = true):
	var diff = frame_vel - reference_frame_vel
	if apply_impulse:
		super.apply_central_impulse(self.mass * diff)
	reference_frame_vel = frame_vel


func apply_relative_central_impulse(impulse : Vector3, relative_multiplier = Vector3.ONE):
	super.apply_central_impulse(impulse + mass * reference_frame_vel * relative_multiplier)



var target_position : Vector3
var target_linear_velocity : Vector3
var target_rotation : Vector3
var target_angular_velocity : Vector3
var current_interpolation_step = 0
#
#
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	pass
	#if not is_multiplayer_authority() and current_interpolation_step < max_interpolation_steps:
		#_interpolate_state(state)
		#if just_spawned:
			#global_position = target_position
			#rotation = target_rotation
			#just_spawned = false
#
#
#func _physics_process(delta: float) -> void:
	#if is_multiplayer_authority():
		#var new_position : Vector3 = global_position
		#var new_linear_velocity : Vector3 = linear_velocity
		#var new_rotation : Vector3 = rotation
		#var new_angular_velocity : Vector3 = angular_velocity
		#if self is HoldableItem and self.being_held:
			#new_linear_velocity = self.item_holder.linear_velocity
		#elif self is Character and self.vehicle:
			#new_linear_velocity = self.vehicle.linear_velocity
			#new_angular_velocity = self.vehicle.angular_velocity
		#sync_state.rpc(new_position, new_linear_velocity, new_rotation, new_angular_velocity)
#
#
#func _interpolate_state(state: PhysicsDirectBodyState3D):
	#global_position = lerp(global_position, target_position, 0.5)
	#state.linear_velocity = lerp(state.linear_velocity, target_linear_velocity, 0.9)
	#rotation = lerp(rotation, target_rotation, 0.5)
	#state.angular_velocity = lerp(state.angular_velocity, target_angular_velocity, 0.9)
	#current_interpolation_step += 1
#
#
#@rpc("authority", "call_remote", "unreliable_ordered")
#func sync_state(new_position : Vector3, new_linear_velocity : Vector3, new_rotation : Vector3, new_angular_velocity : Vector3):
	#target_position = new_position
	#target_linear_velocity = new_linear_velocity
	#target_rotation = new_rotation
	#target_angular_velocity = new_angular_velocity
	#current_interpolation_step = 0

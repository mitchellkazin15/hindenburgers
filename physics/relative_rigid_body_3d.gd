class_name RelativeRigidBody3D
extends RigidBody3D

## Gravity sources join this group so bodies can find them without an overlap.
const GRAVITY_SOURCE_GROUP = "gravity_sources"

## Time constant for chasing networked transforms: 63% of the error in 1/SPEED
## seconds. Higher is snappier and less smooth.
const NETWORK_SMOOTHING_SPEED = 20.0
## Corrections bigger than this are teleports, not motion, so they snap.
const NETWORK_SNAP_DISTANCE = 5.0

@export var max_interpolation_steps = 100

var reference_frame_vel = Vector3.ZERO
var original_gravity_scale : float
var planet_gravity_accel = 0.0
var world_up = Vector3.UP

## True on peers that don't own this body.
var net_smoothing := false
var net_target_position := Vector3.ZERO
var net_target_quaternion := Quaternion.IDENTITY

var _last_synced_position : Vector3 = Vector3.ZERO
var _last_synced_rotation : Vector3 = Vector3.ZERO
var _gravity_source : Node3D = null

var just_spawned = true


func _ready() -> void:
	original_gravity_scale = gravity_scale
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
		# RigidBodySyncManager drives this transform every rendered frame, and
		# network snaps don't land on tick boundaries, so Godot interpolating
		# through them is what clients saw as jitter.
		physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		net_smoothing = true
		net_target_position = position
		net_target_quaternion = quaternion
	set_physics_process(is_multiplayer_authority())
	if MultiplayerManager.safe_is_server():
		RigidBodySyncManager.tracked_bodies.append(self)
	update_world_up()


## Called by RigidBodySyncManager when a state packet lands.
func set_network_transform(new_position : Vector3, new_rotation : Vector3, snap := false) -> void:
	net_target_position = new_position
	net_target_quaternion = Basis.from_euler(new_rotation).get_rotation_quaternion()
	if snap or not net_smoothing or position.distance_to(new_position) > NETWORK_SNAP_DISTANCE:
		position = net_target_position
		quaternion = net_target_quaternion


## Driven once per rendered frame, not per tick - that decoupling is the point.
func advance_network_smoothing(delta : float) -> void:
	if not net_smoothing:
		return
	var t := 1.0 - exp(-NETWORK_SMOOTHING_SPEED * delta)
	position = position.lerp(net_target_position, t)
	quaternion = quaternion.slerp(net_target_quaternion, t)


## world_up isn't replicated. It can't be derived from an overlap either: the
## branch above strips collision shapes on non-authority peers, so
## PlanetGravityArea3D never sees this body there. Position is already synced,
## so every peer can work out the same value locally for free.
func update_world_up() -> Vector3:
	if not _is_source_valid(_gravity_source):
		_gravity_source = _find_gravity_source()
	if _gravity_source == null:
		world_up = Vector3.UP
		return world_up
	var up := _gravity_source.global_position.direction_to(global_position)
	# Dead centre of a planet has no meaningful up.
	world_up = Vector3.UP if up.length_squared() < 0.5 else up
	return world_up


func _is_source_valid(source) -> bool:
	if source == null or not is_instance_valid(source) or not source.is_inside_tree():
		return false
	return global_position.distance_squared_to(source.global_position) <= float(source.influence_radius_squared)


func _find_gravity_source() -> Node3D:
	var nearest : Node3D = null
	var nearest_dist := INF
	for node in get_tree().get_nodes_in_group(GRAVITY_SOURCE_GROUP):
		# Untyped on purpose: naming PlanetGravityArea3D here would make the
		# two scripts cyclically depend on each other's class_name.
		var area = node
		if not is_instance_valid(area) or not area.is_inside_tree():
			continue
		var dist := global_position.distance_squared_to(area.global_position)
		if dist > float(area.influence_radius_squared) or dist >= nearest_dist:
			continue
		nearest_dist = dist
		nearest = area
	return nearest


func set_new_reference_frame(frame_vel : Vector3, apply_impulse = true):
	var diff = frame_vel - reference_frame_vel
	if apply_impulse:
		super.apply_central_impulse(self.mass * diff)
	reference_frame_vel = frame_vel


func apply_relative_central_impulse(impulse : Vector3, state: PhysicsDirectBodyState3D = null):
	var final_impulse : Vector3 = impulse + mass * reference_frame_vel
	if state:
		state.apply_central_impulse(final_impulse)
	else:
		super.apply_central_impulse(final_impulse)

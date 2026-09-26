class_name CameraPivot
extends Node3D

## Holds the camera a fixed distance above follow_body along that body's
## world_up, with an orientation of its own, so a body tipping over doesn't
## drag the view with it.

@export var follow_body : RelativeRigidBody3D
## Distance above follow_body along world_up. Negative derives it from this
## node's offset in the scene at startup.
@export var height := -1.0
@export var tilt_upper_limit := deg_to_rad(89.0)
@export var tilt_lower_limit := deg_to_rad(-89.0)
## Extra easing on top of the body's own network smoothing. 0 disables it;
## easing both only adds lag. Higher = snappier.
@export var follow_smoothing_speed := 0.0

# Yaw is a pending delta about world_up, pitch an absolute angle about our own
# right axis. Never read back out of an Euler decomposition - that inverted
# both controls whenever world_up wasn't +Y.
var _yaw_input := 0.0
var _pitch := 0.0
var _needs_snap := true


func _ready() -> void:
	if height < 0.0:
		height = position.length()
	top_level = true
	# We place this node every rendered frame, so Godot must not interpolate it
	# a second time. Children inherit this.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


## Called by PlayerCamera3D, in radians.
func add_look(yaw_delta : float, pitch_delta : float) -> void:
	_yaw_input += yaw_delta
	_pitch = clampf(_pitch + pitch_delta, tilt_lower_limit, tilt_upper_limit)


## Drop any easing and jump to the body next frame, after a teleport.
func snap_to_body() -> void:
	_needs_snap = true


func _process(delta : float) -> void:
	if follow_body == null or not is_instance_valid(follow_body):
		return

	var up := follow_body.update_world_up()

	# Flatten last frame's forward into the new up's tangent plane. This strips
	# the old pitch too, so re-applying _pitch can't accumulate or slip past
	# its clamp when world_up rotates underneath us.
	var forward := -global_basis.z
	forward -= up * forward.dot(up)
	if forward.length_squared() < 0.0001:
		# Forward collapsed onto up; the old up is perpendicular to it.
		forward = global_basis.y
		forward -= up * forward.dot(up)
	if forward.length_squared() < 0.0001:
		forward = up.cross(Vector3.RIGHT if absf(up.x) < 0.9 else Vector3.FORWARD)
	forward = forward.normalized().rotated(up, _yaw_input)
	_yaw_input = 0.0

	var flat := Basis.looking_at(forward, up)
	basis = flat.rotated(flat.x, _pitch)

	# Sample the transform the body is being drawn at, not its last tick.
	var target_position := follow_body.get_global_transform_interpolated().origin + height * up
	var can_ease := (
		follow_smoothing_speed > 0.0
		and not _needs_snap
		and global_position.distance_to(target_position) < RelativeRigidBody3D.NETWORK_SNAP_DISTANCE
	)
	if can_ease:
		global_position = global_position.lerp(
			target_position, 1.0 - exp(-follow_smoothing_speed * delta)
		)
	else:
		global_position = target_position
	_needs_snap = false

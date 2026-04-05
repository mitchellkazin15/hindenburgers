class_name Character
extends RigidBody3D

signal locked_interaction_ended

@onready var rotation_pivot = $RotationPivot

@export var camera : Camera3D
@export var controllable = true
@export var input_controller : CharacterPlayerInputController
@export var synchronizer : MultiplayerSynchronizer
@export var initial_multiplayer_authority : int
@export var initial_position : Vector3
@export var display_name = ""
@export var floor_shape_cast : ShapeCast3D
@export var stats : CharacterStatManager
@export var hand : RemoteTransform3D
@export var randomness_duration = 1.0

const host_authority = 1
var move_direction : Vector3
var is_jumping = false
var is_sprinting = false
var locked_interaction = false
var held_item : HoldableItem = null
var reset_input = false

var speed = 20.0
var jump_speed = 20.0
var jump_lockout_time = 0.1
var launched = false
var prev_relative_vel = Vector3.ZERO

var randomness_timer : SceneTreeTimer
var rand_speed = 0.0
var rand_angle = 0.0
var _jump_lock_timer : SceneTreeTimer
var _can_jump = true

var throw_item_stopwatch : Stopwatch
var use_item_stopwatch : Stopwatch


func _enter_tree() -> void:
	position = initial_position
	set_multiplayer_authority(host_authority, true)
	set_process(multiplayer.is_server())
	set_physics_process(multiplayer.is_server())
	set_process_input(multiplayer.is_server())


func _ready() -> void:
	randomness_timer = get_tree().create_timer(0.0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	use_item_stopwatch = StopwatchManager.create_stopwatch()
	throw_item_stopwatch = StopwatchManager.create_stopwatch()
	use_item_stopwatch.stop()
	throw_item_stopwatch.stop()
	$Label3D.text = display_name


@rpc("any_peer", "call_local", "reliable")
func set_initial_values(pos, multiplayer_authority):
	position = pos
	set_multiplayer_authority(host_authority, true)
	set_process(multiplayer.is_server())
	set_physics_process(multiplayer.is_server())
	set_process_input(multiplayer.is_server())
	camera.set_multiplayer_authority(multiplayer_authority)
	camera.set_process(camera.is_multiplayer_authority())
	camera.set_process_input(camera.is_multiplayer_authority())
	camera.current = camera.is_multiplayer_authority()
	input_controller.set_multiplayer_authority(multiplayer_authority)
	input_controller.set_process(input_controller.is_multiplayer_authority())
	input_controller.set_process_input(input_controller.is_multiplayer_authority())
	if not camera.is_multiplayer_authority():
		$HUD.hide()
		$DrugManager/DrugScreenEffectQuad.hide()
	synchronizer.set_multiplayer_authority(host_authority)
	$Label3D.text = display_name


func reset():
	if locked_interaction:
		print("sending reset result to: ", camera.get_multiplayer_authority())
		end_locked_interaction.rpc_id(camera.get_multiplayer_authority())
		end_locked_interaction()
	freeze = true
	position = initial_position
	linear_velocity = Vector3.ZERO
	freeze = false
	reset_input = false


func set_locked_interacting(change_camera : bool):
	prev_relative_vel = Vector3.ZERO
	locked_interaction = true
	controllable = false
	if change_camera:
		camera.current = false
	freeze = true


@rpc("any_peer", "call_local", "reliable")
func end_locked_interaction():
	locked_interaction = false
	controllable = true
	camera.current = camera.is_multiplayer_authority()
	freeze = false
	rotation = Vector3.ZERO
	locked_interaction_ended.emit()


func grab_item(item : HoldableItem):
	if held_item != null:
		return false
	use_item_stopwatch.restart()
	throw_item_stopwatch.restart()
	hand.remote_path = item.get_path()
	hand.update_rotation = true
	hand.rotation = Vector3.ZERO
	held_item = item
	held_item.use_finished.connect(_on_use_finished)
	return true


func start_use_item():
	use_item_stopwatch.restart()
	use_item_stopwatch.start()
	if held_item:
		held_item.start_use()


func use_item():
	use_item_stopwatch.stop()
	if held_item:
		hand.update_rotation = not held_item.unlock_rotation_on_use
		held_item.use(use_item_stopwatch.time_elapsed_sec)
	use_item_stopwatch.restart()


func _on_use_finished():
	hand.update_rotation = true


func start_throw_item():
	throw_item_stopwatch.restart()
	throw_item_stopwatch.start()


func throw_item():
	throw_item_stopwatch.stop()
	if held_item == null:
		throw_item_stopwatch.restart()
		return
	hand.remote_path = NodePath("")
	hand.rotation = Vector3.ZERO
	held_item.use_finished.disconnect(_on_use_finished)
	held_item.release()
	var throw_vec : Vector3 = ($RotationPivot.global_basis.z).normalized()
	throw_vec += held_item.mass * Vector3(0.1, .5, 0.1) * linear_velocity
	throw_vec = throw_vec.rotated(Vector3.UP, rand_angle)
	var charge_time = min(stats.get_current_max_throw_charge_time(), throw_item_stopwatch.time_elapsed_sec)
	if charge_time < 0.25:
		charge_time = 0.0
	throw_vec *= stats.get_current_throw_strength() * charge_time
	held_item.apply_central_impulse(throw_vec)
	held_item = null
	throw_item_stopwatch.restart()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not is_multiplayer_authority():
		return
	if not controllable:
		return
	if reset_input:
		reset()
		return
	var collider = null;
	if floor_shape_cast.get_collision_count() > 0:
		launched = false
		collider = floor_shape_cast.get_collider(0)
	var relative_linear_vel = state.linear_velocity
	if collider:
		if collider is Vehicle or collider is Character:
			prev_relative_vel = collider.linear_velocity
		else:
			prev_relative_vel = Vector3.ZERO
	relative_linear_vel -= prev_relative_vel
	if randomness_timer.time_left == 0.0:
		var speed_randomness = stats.get_current_speed_randomness()
		var new_rand_speed = max(0.0, randf_range(-speed_randomness, speed_randomness))
		var angle_randomness = deg_to_rad(stats.get_current_direction_angle_randomness_degrees())
		var new_rand_angle = randf_range(-angle_randomness, angle_randomness)
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rand_speed", new_rand_speed, randomness_duration / 2.0)
		tween.tween_property(self, "rand_angle", new_rand_angle, randomness_duration / 2.0)
		randomness_timer = get_tree().create_timer(randomness_duration)
	var speed = max(1.0, stats.get_current_speed() + rand_speed)
	if move_direction != Vector3.ZERO:
		$RotationPivot.rotation.y = lerp_angle($RotationPivot.rotation.y, global_basis.z.signed_angle_to(move_direction, Vector3.UP), min(10.0 * state.step, 1.0))
	if is_sprinting:
		speed *= stats.get_current_sprint_multiplier()
	var target_ground_plane_vel : Vector3 = (speed * move_direction)
	target_ground_plane_vel = target_ground_plane_vel.rotated(Vector3.UP, rand_angle)
	if launched:
		target_ground_plane_vel.y = 0.0
		state.apply_central_force(target_ground_plane_vel.normalized() * stats.get_current_air_acceleration())
	else:
		target_ground_plane_vel -= relative_linear_vel
		target_ground_plane_vel.y = 0.0
		state.apply_central_impulse(target_ground_plane_vel)
	if is_jumping and _can_jump and collider:
		state.apply_central_impulse(stats.get_current_jump_impulse() * Vector3.UP)
		_can_jump = false
		_jump_lock_timer = get_tree().create_timer(jump_lockout_time)
		_jump_lock_timer.timeout.connect(_on_jump_lock_timeout)


func _on_jump_lock_timeout():
	_can_jump = true

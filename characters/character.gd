class_name Character
extends RelativeRigidBody3D

signal locked_interaction_ended

@onready var rotation_pivot = $RotationPivot

@export var camera : Camera3D
@export var interact_raycast : InteractionRayCast3D
@export var controllable = true
@export var input_controller : CharacterPlayerInputController
@export var synchronizer : MultiplayerSynchronizer
@export var initial_multiplayer_authority : int = 1
@export var initial_position : Vector3
@export var display_name = ""
@export var floor_shape_cast : ShapeCast3D
@export var stats : CharacterStatManager
@export var hand : RemoteTransform3D
@export var randomness_duration = 1.0
@export var holding_item = false

var move_direction : Vector3
var is_jumping = false
var is_sprinting = false
var locked_interaction = false
var vehicle : Vehicle
var held_item : HoldableItem = null
var reset_input = false

var randomness_timer : SceneTreeTimer
var rand_speed = 0.0
var rand_angle = 0.0
var jump_lockout_time = 0.1
var _jump_lock_timer : SceneTreeTimer
var _can_jump = true
var launched_timer : SceneTreeTimer
var launched_time = 0.1
var launched = false

var throw_item_stopwatch : Stopwatch
var use_item_stopwatch : Stopwatch


func _ready() -> void:
	super._ready()
	randomness_timer = get_tree().create_timer(0.0)
	_jump_lock_timer = get_tree().create_timer(0.0)
	launched_timer = get_tree().create_timer(0.0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	use_item_stopwatch = StopwatchManager.create_stopwatch()
	throw_item_stopwatch = StopwatchManager.create_stopwatch()
	use_item_stopwatch.stop()
	throw_item_stopwatch.stop()
	$Label3D.text = display_name
	set_initial_values()


func set_initial_values():
	set_process(MultiplayerManager.safe_is_server())
	set_physics_process(MultiplayerManager.safe_is_server())
	set_process_input(MultiplayerManager.safe_is_server())
	camera.set_multiplayer_authority(initial_multiplayer_authority)
	camera.set_process(camera.is_multiplayer_authority())
	camera.set_process_input(camera.is_multiplayer_authority())
	camera.current = initial_multiplayer_authority == multiplayer.get_unique_id()
	if camera.current:
		$/root/Main/MultiplayerBaseScene/LevelRoot/Level/Terrain3D.set_camera(camera)
	input_controller.set_multiplayer_authority(initial_multiplayer_authority)
	input_controller.set_process(input_controller.is_multiplayer_authority())
	input_controller.set_process_input(input_controller.is_multiplayer_authority())
	interact_raycast.set_multiplayer_authority(initial_multiplayer_authority)
	interact_raycast.set_physics_process(interact_raycast.is_multiplayer_authority())
	$Label3D.text = display_name
	if multiplayer.get_unique_id() != initial_multiplayer_authority:
		$HUD.hide()
		$DrugManager/DrugScreenEffectQuad.hide()
		$Label3D.show()
	else:
		$HUD.show()
		$DrugManager/DrugScreenEffectQuad.show()
		$Label3D.hide()


func reset():
	if locked_interaction:
		end_locked_interaction.rpc_id(camera.get_multiplayer_authority())
		end_locked_interaction()
	freeze = true
	position = initial_position
	rotation = Vector3.ZERO
	set_new_reference_frame(Vector3.ZERO)
	freeze = false
	reset_input = false
	$DrugManager.clear_drug_visual_effects.rpc()


func set_locked_interacting(change_camera : bool, vehicle : Vehicle = null):
	locked_interaction = true
	controllable = false
	self.vehicle = vehicle
	rotation_pivot.rotation = Vector3.ZERO
	if change_camera:
		camera.current = false
	freeze = true


@rpc("any_peer", "call_local", "reliable")
func end_locked_interaction():
	locked_interaction = false
	controllable = true
	camera.current = camera.is_multiplayer_authority()
	freeze = false
	vehicle = null
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
	holding_item = true
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


func throw_item(aim_dir : Vector3):
	throw_item_stopwatch.stop()
	if held_item == null:
		throw_item_stopwatch.restart()
		return
	hand.remote_path = NodePath("")
	hand.rotation = Vector3.ZERO
	held_item.use_finished.disconnect(_on_use_finished)
	held_item.release()
	var throw_vec : Vector3 = (aim_dir + Vector3(0.0, 0.1, 0.0)).normalized()
	if reference_frame_vel.length() == 0.0:
		throw_vec += held_item.mass * Vector3(0.1, .5, 0.1) * linear_velocity
	throw_vec = throw_vec.rotated(Vector3.UP, rand_angle)
	var charge_time = min(stats.get_current_max_throw_charge_time(), throw_item_stopwatch.time_elapsed_sec)
	if charge_time < 0.25:
		charge_time = 0.0
	throw_vec *= stats.get_current_throw_strength() * charge_time
	held_item.set_new_reference_frame(self.reference_frame_vel)
	held_item.apply_central_impulse(throw_vec)
	held_item = null
	holding_item = false
	throw_item_stopwatch.restart()


func set_launched():
	launched_timer = get_tree().create_timer(launched_time)
	launched = true


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	if held_item == null or not is_instance_valid(held_item):
		held_item = null
		hand.remote_path = NodePath("")
		holding_item = false
	if reset_input:
		reset()
		return
	if not controllable:
		return
	var collider = null;
	if floor_shape_cast.get_collision_count() > 0:
		if launched_timer.time_left == 0.0:
			launched = false
		collider = floor_shape_cast.get_collider(0)
	if randomness_timer.time_left == 0.0:
		var speed_randomness = stats.get_current_speed_randomness()
		var new_rand_speed = max(0.0, randf_range(-speed_randomness, speed_randomness))
		var angle_randomness = deg_to_rad(stats.get_current_direction_angle_randomness_degrees())
		var new_rand_angle = randf_range(-angle_randomness, angle_randomness)
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rand_speed", new_rand_speed, randomness_duration / 2.0)
		tween.tween_property(self, "rand_angle", new_rand_angle, randomness_duration / 2.0)
		randomness_timer = get_tree().create_timer(randomness_duration)
	var speed = calculate_speed()
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
		target_ground_plane_vel -= linear_velocity
		target_ground_plane_vel.y = 0.0
		self.apply_relative_central_impulse(target_ground_plane_vel, Vector3(1.0, 0.0, 1.0))
	if is_jumping and _can_jump and collider:
		var jump_impulse = stats.get_current_jump_impulse() * Vector3.UP
		jump_impulse -= (state.linear_velocity.y - reference_frame_vel.y) * mass * Vector3.UP
		self.apply_central_impulse(jump_impulse)
		_can_jump = false
		_jump_lock_timer = get_tree().create_timer(jump_lockout_time)
		_jump_lock_timer.timeout.connect(_on_jump_lock_timeout)


func calculate_speed():
	var speed = max(1.0, stats.get_current_speed() + rand_speed)
	speed /= (mass + (0.0 if not held_item else held_item.mass))
	return speed


func _on_jump_lock_timeout():
	_can_jump = true

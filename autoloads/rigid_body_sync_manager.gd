extends Node

const SYNC_RATIO_DIVISOR = 2

enum StateIndices {ID = 0, POS = 1, ROT = 2}

var tracked_bodies: Array[RelativeRigidBody3D] = []
var frames_since_last_sync = 1
var invalidate_cached_states = false


func _physics_process(delta):
	if EventService.state != EventService.GameState.IN_GAME:
		tracked_bodies = []
		return
	if not MultiplayerManager.safe_is_server():
		return
	if frames_since_last_sync % SYNC_RATIO_DIVISOR != 0:
		frames_since_last_sync += 1
		return
	frames_since_last_sync = 0
	var states = []
	var erase_array = []
	for body in tracked_bodies:
		if not is_instance_valid(body):
			continue
		if (invalidate_cached_states or 
			(body.position.distance_squared_to(body._last_synced_position) > 0.001 or 
			body.rotation.distance_squared_to(body._last_synced_rotation) > 0.001)
		):
			states.append(generate_state(body))
			body._last_synced_position = body.position
			body._last_synced_rotation = body.rotation
	if states.size() > 0:
		sync_states.rpc(states)
	invalidate_cached_states = false


func generate_state(body : RelativeRigidBody3D) -> Array:
	return [
		body.get_path(),
		body.position,
		body.rotation,
	]


@rpc("any_peer", "call_local", "unreliable_ordered")
func set_invalidate_cached_states():
	print("invalidated cached body states! ", multiplayer.get_unique_id())
	invalidate_cached_states = true


@rpc("authority", "call_remote", "unreliable_ordered")
func sync_states(states: Array):
	if EventService.state != EventService.GameState.IN_GAME:
		return
	for state in states:
		if not has_node(state[StateIndices.ID]):
			continue
		var body : Node3D = get_node(state[StateIndices.ID])
		if body and is_instance_valid(body):
			body.position = state[StateIndices.POS]
			body.rotation = state[StateIndices.ROT]

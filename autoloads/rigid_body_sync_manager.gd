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


# Server-only: build a snapshot of every tracked body and send it reliably to a
# single peer. Use this when a new peer has finished spawning and needs the
# current state of every body, especially idle ones that wouldn't otherwise
# show up in the regular delta sync.
func push_full_state_to(peer_id : int) -> void:
	if not MultiplayerManager.safe_is_server():
		return
	if peer_id == multiplayer.get_unique_id():
		return
	var states = []
	for body in tracked_bodies:
		if not is_instance_valid(body):
			continue
		states.append(generate_state(body))
		body._last_synced_position = body.position
		body._last_synced_rotation = body.rotation
	if states.size() > 0:
		sync_states_reliable.rpc_id(peer_id, states)


@rpc("any_peer", "call_local", "reliable")
func set_invalidate_cached_states():
	print("invalidated cached body states! ", multiplayer.get_unique_id())
	invalidate_cached_states = true


@rpc("authority", "call_remote", "unreliable_ordered")
func sync_states(states: Array):
	_apply_states(states)


# Reliable variant of sync_states for one-shot bootstrap pushes (e.g. when a
# peer joins). Regular per-frame deltas should keep using sync_states.
@rpc("authority", "call_remote", "reliable")
func sync_states_reliable(states: Array):
	_apply_states(states)


func _apply_states(states: Array) -> void:
	if EventService.state != EventService.GameState.IN_GAME:
		return
	for state in states:
		var node_path = state[StateIndices.ID]
		if not has_node(node_path):
			push_warning("RigidBodySyncManager: no node at path %s" % [node_path])
			continue
		var body : Node3D = get_node(node_path)
		if body and is_instance_valid(body):
			body.position = state[StateIndices.POS]
			body.rotation = state[StateIndices.ROT]

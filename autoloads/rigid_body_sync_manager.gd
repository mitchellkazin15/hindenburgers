extends Node

const SYNC_RATIO_DIVISOR = 2

enum StateIndices {ID = 0, POS = 1, ROT = 2}

var tracked_bodies: Array[RelativeRigidBody3D] = []
var frames_since_last_sync = 1

func _physics_process(delta):
	if not multiplayer.is_server():
		return
	if frames_since_last_sync % SYNC_RATIO_DIVISOR != 0:
		frames_since_last_sync += 1
		return
	frames_since_last_sync = 0
	var states = []
	for body in tracked_bodies:
		if (body.position.distance_squared_to(body._last_synced_position) > 0.001 or 
			body.rotation.distance_squared_to(body._last_synced_rotation) > 0.001):
			states.append([
				body.get_path(),
				body.position,
				body.rotation,
			])
			body._last_synced_position = body.position
			body._last_synced_rotation = body.rotation
	if states.size() > 0:
		sync_states.rpc(states)

@rpc("authority", "unreliable_ordered")
func sync_states(states: Array):
	for state in states:
		var body = get_node(state[StateIndices.ID])
		if body:
			body.position = state[StateIndices.POS]
			body.rotation = state[StateIndices.ROT]

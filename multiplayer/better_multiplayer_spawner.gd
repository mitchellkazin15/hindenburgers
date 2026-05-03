class_name BetterMultiplayerSpawner
extends MultiplayerSpawner

var per_peer_spawn_count_dict = {}
var per_peer_spawn_ready_dict = {}
# Server-only: tracks which peers we've already pushed a full RigidBody state
# snapshot to. Prevents redundant pushes if a peer's spawn count later
# fluctuates (e.g. when new entities spawn after the initial join).
var _peers_state_pushed = {}
var update_spawn_count_timer : SceneTreeTimer


func _ready() -> void:
	update_spawn_count_timer = get_tree().create_timer(0.0)
	spawn_function = _custom_spawn_func
	spawned.connect(_on_spawned)
	despawned.connect(_on_despawned)
	per_peer_spawn_ready_dict[1] = true


func spawn_player(player: Character):
	spawn({
		"scene_file_path": "res://characters/player.tscn",
		"position": player.initial_position,
		"authority": player.initial_multiplayer_authority,
		"display_name": player.display_name
	})


@rpc("any_peer", "call_local", "reliable")
func update_per_peer_spawn_count(peer_id, new_count):
	print("updated ", peer_id, " with count ", new_count)
	if not MultiplayerManager.safe_is_server():
		return
	print("expecting ", get_node(spawn_path).get_children().size())
	per_peer_spawn_count_dict[peer_id] = new_count
	var is_fully_spawned = _peer_fully_spawned(peer_id)
	sync_ready_dict.rpc(peer_id, is_fully_spawned)
	# When a remote peer first finishes spawning everything the server has,
	# push the authoritative position/rotation of every tracked rigid body
	# to that peer. This is the bootstrap snapshot that gets idle bodies
	# (notably stationary players) into the right place — they wouldn't
	# otherwise show up in the regular delta sync until they moved.
	if (is_fully_spawned and peer_id != 1
		and not _peers_state_pushed.has(peer_id)):
		_peers_state_pushed[peer_id] = true
		RigidBodySyncManager.push_full_state_to(peer_id)


@rpc("any_peer", "call_local", "reliable")
func sync_ready_dict(peer_id : int, is_ready : bool):
	per_peer_spawn_ready_dict[peer_id] = is_ready


func is_locally_synced() -> bool:
	return (
		multiplayer.has_multiplayer_peer() and
		per_peer_spawn_ready_dict.has(multiplayer.get_unique_id()) and 
		per_peer_spawn_ready_dict[multiplayer.get_unique_id()]
	)


func _peer_fully_spawned(peer_id) -> bool:
	if peer_id == 1:
		return true
	if per_peer_spawn_count_dict.keys().has(peer_id):
		print(per_peer_spawn_count_dict[peer_id], "/", get_node(spawn_path).get_children().size())
	return (
		per_peer_spawn_count_dict.keys().has(peer_id) and 
		per_peer_spawn_count_dict[peer_id] == get_node(spawn_path).get_children().size()
	)


func _custom_spawn_func(data: Dictionary) -> Node:
	var node : Node = load(data["scene_file_path"]).instantiate()
	if node is Character:
		node.initial_position = data["position"]
		node.initial_multiplayer_authority = data["authority"]
		node.display_name = data["display_name"]
	if data.has("position"):
		node.position = data["position"]
	if data.has("rotation"):
		node.rotation = data["rotation"]
	node.top_level = true
	node.name = node.name
	return node  # Spawner adds this to the scene automatically


func _on_spawned(node: Node):
	print(node.name, " ready: ", node.is_node_ready(), " node spawned on: ", multiplayer.get_unique_id())
	update_per_peer_spawn_count.rpc(multiplayer.get_unique_id(), get_node(spawn_path).get_children().size())
	if node is Character:
		# Node is fully in the tree and _ready has run on all children
		var peer_id = node.initial_multiplayer_authority


func _on_despawned(node: Node):
	print(node.name, " node despawned on: ", multiplayer.get_unique_id())
	update_per_peer_spawn_count.rpc(multiplayer.get_unique_id(), get_node(spawn_path).get_children().size())

class_name BetterMultiplayerSpawner
extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = _custom_spawn_func
	spawned.connect(_on_character_spawned)


func spawn_player(player: Character):
	spawn({
		"scene_file_path": "res://characters/player.tscn",
		"position": player.initial_position,
		"authority": player.initial_multiplayer_authority,
		"display_name": player.display_name
	})


func _custom_spawn_func(data: Dictionary) -> Node:
	var node = load(data["scene_file_path"]).instantiate()
	if node is Character:
		node.initial_position = data["position"]
		node.initial_multiplayer_authority = data["authority"]
		node.display_name = data["display_name"]
	return node  # Spawner adds this to the scene automatically


func _on_character_spawned(node: Node):
	print(node.name, " ready: ", node.is_node_ready(), " node spawned on: ", multiplayer.get_unique_id())
	if node is Character:
		# Node is fully in the tree and _ready has run on all children
		var peer_id = node.initial_multiplayer_authority
		node.set_initial_values.rpc(node.initial_position, peer_id)
		RigidBodySyncManager.set_invalidate_cached_states.rpc_id(1)

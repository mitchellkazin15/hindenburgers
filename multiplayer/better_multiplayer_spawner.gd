class_name BetterMultiplayerSpawner
extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = _custom_spawn_func
	spawned.connect(_on_character_spawned)


func spawn_player(player: Character):
	spawn({
		"position": player.initial_position,
		"authority": player.initial_multiplayer_authority
	})


func _custom_spawn_func(data: Dictionary) -> Node:
	var player = load("res://characters/player.tscn").instantiate()
	player.initial_position = data["position"]
	player.initial_multiplayer_authority = data["authority"]
	return player  # Spawner adds this to the scene automatically


func _on_character_spawned(node: Node):
	if node is Character:
		print(node.name, " ready: ", node.is_node_ready(), " node spawned on: ", multiplayer.get_unique_id())
		# Node is fully in the tree and _ready has run on all children
		var peer_id = node.initial_multiplayer_authority
		node.set_initial_values.rpc(node.initial_position, peer_id)

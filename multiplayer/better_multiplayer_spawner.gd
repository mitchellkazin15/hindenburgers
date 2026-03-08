class_name BetterMultiplayerSpawner
extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = _custom_spawn_func


func spawn_player(player: Character):
	spawn({
		"position": player.initial_position,
		"authority": player.initial_multiplayer_authority
	})

func _custom_spawn_func(data: Dictionary) -> Node:
	var player = load("res://characters/character.tscn").instantiate()
	player.initial_position = data["position"]
	player.initial_multiplayer_authority = data["authority"]
	return player  # Spawner adds this to the scene automatically

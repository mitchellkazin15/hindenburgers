extends Node

signal quit_game
signal change_menu_overlay(menu_path)
signal start_game(game_info : Dictionary)
signal load_multiplayer_level


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	change_menu_overlay.connect(_change_menu)
	start_game.connect(_start_game)
	load_multiplayer_level.connect(_on_load_multiplayer_level)
	quit_game.connect(_quit_game)


func _change_menu(menu_path):
	for child in get_tree().current_scene.get_children():
		if child is MenuContainer:
			child.replace_menu(menu_path)
			return


func _start_game(info):
	print("start event for peer: ", multiplayer.get_unique_id())
	get_tree().change_scene_to_packed(load("res://multiplayer/multiplayer_base_scene.tscn"))
	#deferred_change_scene_to_packed(load("res://multiplayer/multiplayer_base_scene.tscn"))


func deferred_change_scene_to_packed(next_scene):
	var old_scene = get_tree().current_scene
	for child in old_scene.get_children():
		child.queue_free()
	call_deferred("_deferred_change_scene_to_packed_helper", next_scene)


func _deferred_change_scene_to_packed_helper(next_scene):
	get_tree().change_scene_to_packed(next_scene)


func _on_load_multiplayer_level():
	var parent_node = $/root/MultiplayerBaseScene/LevelRoot
	var spawner : BetterMultiplayerSpawner = $/root/MultiplayerBaseScene/MultiplayerSpawner
	var level = load("res://test_levels/level.tscn").instantiate()
	parent_node.add_child(level)
	level.owner = parent_node
	var player_spawns = get_tree().get_nodes_in_group("player_spawn")
	var peer_ids = MultiplayerManager.players.keys()
	var players = []
	for player_num in peer_ids.size():
		print("spawning peer: ", peer_ids[player_num], " is local authority: ", peer_ids[player_num] == multiplayer.get_unique_id())
		var player : Character = load("res://characters/character.tscn").instantiate()
		player.intitial_multiplayer_authority = peer_ids[player_num]
		player.initial_position = player_spawns[player_num].global_position
		spawner.spawn_player(player)
		#player.set_multiplayer_authority(peer_ids[player_num])
		#player.position = player_spawns[player_num].global_position
		#parent_node.add_child(player, true)
		#player.set_initial_values.rpc(player_spawns[player_num].global_position, peer_ids[player_num])
		#player.intitial_multiplayer_authority = peer_ids[player_num]
		#player.initial_position = player_spawns[player_num].global_position
		#parent_node.add_child(player, true)
		#players.append(player)
	call_deferred("_broadcast_player_initial_values", players)


func _broadcast_player_initial_values(players: Array) -> void:
	await get_tree().create_timer(1).timeout
	for player : Character in players:
		player.broadcast_initial_values()


func _quit_game():
	get_tree().quit()

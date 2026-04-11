extends Node

enum GameState {MENU, IN_GAME}

signal quit_game
signal change_menu_overlay(menu_path)
signal start_game(game_info : Dictionary)
signal load_multiplayer_level

var spawner : BetterMultiplayerSpawner
var state : GameState


func _ready():
	state = GameState.MENU
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
	get_tree().change_scene_to_packed(load("res://multiplayer/multiplayer_base_scene.tscn"))


func _input(event):
	if state == GameState.MENU:
		return
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


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
		var player : Character = load("res://characters/player.tscn").instantiate()
		player.initial_multiplayer_authority = peer_ids[player_num]
		player.initial_position = player_spawns[player_num].global_position
		player.display_name = MultiplayerManager.players[peer_ids[player_num]]["name"]
		spawner.spawn_player(player)
	set_game_state.rpc(GameState.IN_GAME)


@rpc("any_peer", "call_local", "reliable")
func set_game_state(new_state : GameState):
	state = new_state


func _quit_game():
	get_tree().quit()

extends Node

enum GameState {MENU, LOADING, IN_GAME}

signal change_menu_overlay(menu_path)
signal change_scene(scene_path)
signal change_settings_overlay_state(show : bool)
signal start_game(game_info : Dictionary)
signal load_multiplayer_level
signal load_in_progress_state_for_peer(peer_id)
signal quit_game

var spawner : BetterMultiplayerSpawner
var state : GameState


func _ready():
	state = GameState.MENU
	process_mode = Node.PROCESS_MODE_ALWAYS
	change_menu_overlay.connect(_change_menu)
	change_scene.connect(_on_changed_scene)
	change_settings_overlay_state.connect(_change_settings_overlay_state)
	start_game.connect(_start_game)
	load_multiplayer_level.connect(_on_load_multiplayer_level)
	load_in_progress_state_for_peer.connect(_on_load_in_progress_state_for_peer)
	quit_game.connect(_quit_game)
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
	MultiplayerManager.server_disconnected.connect(_on_server_disconnected)


func _change_menu(menu_path):
	for child in get_tree().current_scene.get_children():
		if child is MenuContainer:
			child.replace_menu(menu_path)
			return


func _on_changed_scene(scene_path : String):
	pass


func _on_player_disconnected(peer_id):
	if not multiplayer.has_multiplayer_peer() or not MultiplayerManager.safe_is_server() or state != GameState.IN_GAME:
		return
	var character = find_player_by_peer(peer_id)
	character.end_locked_interaction.rpc()
	if character.held_item:
		character.held_item.release()
	character.queue_free()


func find_player_by_peer(peer_id) -> Character:
	for node in $/root/Main/MultiplayerBaseScene/LevelRoot.get_children():
		if node is Character and node.initial_multiplayer_authority == peer_id:
			var character : Character = node
			return character
	return null


func _on_server_disconnected(peer_id):
	return_all_peers_to_menu.rpc()


@rpc("authority", "call_remote", "reliable")
func return_all_peers_to_menu():
	EventService.change_menu_overlay.emit("res://ui/title_menu.tscn")
	return_to_menu()


func _on_load_in_progress_state_for_peer(peer_id):
	_start_game.rpc_id(peer_id, {})


func _change_settings_overlay_state(show : bool):
	if show:
		SettingsScreen.show()
		SettingsScreen.process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	else:
		SettingsScreen.hide()
		SettingsScreen.process_mode = ProcessMode.PROCESS_MODE_DISABLED


func clear_level_root():
	for child in $/root/Main/MultiplayerBaseScene/LevelRoot.get_children():
		child.queue_free()


@rpc("authority", "call_remote", "reliable")
func _start_game(info):
	$/root/Main/Background.hide()
	$/root/Main/Background.process_mode = Node.PROCESS_MODE_DISABLED
	$/root/Main/MenuContainer.hide()
	$/root/Main/MenuContainer.process_mode = Node.PROCESS_MODE_DISABLED
	state = GameState.LOADING
	MultiplayerManager.player_loaded.rpc()
	if MultiplayerManager.safe_is_server():
		call_deferred("_on_load_multiplayer_level")


func return_to_menu():
	state = GameState.MENU
	$/root/Main/Background.show()
	$/root/Main/Background.process_mode = Node.PROCESS_MODE_ALWAYS
	$/root/Main/MenuContainer.show()
	$/root/Main/MenuContainer.process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	PauseScreen.hide_menu()


func _unhandled_input(event: InputEvent) -> void:
	if state == GameState.MENU:
		return
	if event.is_action_pressed("left_click") and not PauseScreen.displayed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("exit"):
		handle_in_game_menu_change()


func handle_in_game_menu_change():
	PauseScreen.pause_state_changed()
	if PauseScreen.displayed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_load_multiplayer_level():
	print("loading level: ", multiplayer.get_unique_id())
	clear_level_root()
	LevelSaveManager.load_level()
	var peer_ids = MultiplayerManager.players.keys()
	print(peer_ids)
	for player_num in peer_ids.size():
		spawn_new_player(peer_ids[player_num], player_num)
	state = GameState.IN_GAME


func spawn_new_player(peer_id, player_num):
	var player_spawns = get_tree().get_nodes_in_group("player_spawn")
	var spawner : BetterMultiplayerSpawner = $/root/Main/MultiplayerBaseScene/MultiplayerSpawner
	print("spawning peer: ", peer_id, " is local authority: ", peer_id == multiplayer.get_unique_id())
	var player : Character = load("res://characters/player.tscn").instantiate()
	player.initial_multiplayer_authority = peer_id
	player.initial_position = player_spawns[player_num].global_position
	player.display_name = MultiplayerManager.players[peer_id]["name"]
	spawner.spawn_player(player)
	RigidBodySyncManager.set_invalidate_cached_states.rpc()


@rpc("any_peer", "call_local", "reliable")
func set_game_state(new_state : GameState):
	state = new_state


func _quit_game():
	get_tree().quit()


func _physics_process(delta: float) -> void:
	if state != GameState.LOADING:
		LoadingScreen.hide()
	else:
		LoadingScreen.show()
	if not multiplayer.has_multiplayer_peer():
		return
	var spawner : BetterMultiplayerSpawner = $/root/Main/MultiplayerBaseScene/MultiplayerSpawner
	if spawner.is_locally_synced() and find_player_by_peer(multiplayer.get_unique_id()):
		state = GameState.IN_GAME
		RigidBodySyncManager.set_invalidate_cached_states.rpc()

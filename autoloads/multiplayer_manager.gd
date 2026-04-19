extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal client_disconnected

const PORT = 12782 # Multiply by 10 and look up Unicode by decimal value :)
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 16

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}
var players_loaded = 0
var stats_timer : SceneTreeTimer


func _ready():
	stats_timer = get_tree().create_timer(0.0)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	players[1] = player_info
	player_connected.emit(1, player_info)


func remove_multiplayer_peer():
	if MultiplayerManager.safe_is_server():
		print("local server disconnected")
		players = {}
	multiplayer.multiplayer_peer = null
	client_disconnected.emit()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("authority", "call_local", "reliable")
func start_game_for_peers(game_info):
	print("starting on peer: ", multiplayer.get_unique_id())
	EventService.start_game.emit(game_info)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	print("player_loaded: ", multiplayer.get_unique_id())


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	print("new player")
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	if MultiplayerManager.safe_is_server() and EventService.state == EventService.GameState.IN_GAME:
		EventService.load_in_progress_state_for_peer.emit(new_player_id)
		EventService.spawn_new_player(new_player_id, players.size())


func _on_player_disconnected(id):
	print("player disconnected: ", id)
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	print("remote server disconnected")
	EventService.return_all_peers_to_menu()
	EventService.clear_level_root()
	multiplayer.multiplayer_peer = null
	players = {}


func broadcast_queue_free(node : Node):
	if not MultiplayerManager.safe_is_server():
		return
	if node is RelativeRigidBody3D and node in RigidBodySyncManager.tracked_bodies:
		RigidBodySyncManager.tracked_bodies.erase(node)
	if node.get_parent() == $/root/Main/MultiplayerBaseScene/LevelRoot:
		node.queue_free()
	else:
		_queue_free_on_peers.rpc(node.get_path())


@rpc("any_peer", "call_local", "reliable")
func _queue_free_on_peers(node_path : String):
	if has_node(node_path):
		get_node(node_path).queue_free()


func add_node_to_spawner(scene_path : String, position : Vector3, rotation = Vector3.ZERO) -> Node:
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	var spawner : BetterMultiplayerSpawner = $/root/Main/MultiplayerBaseScene/MultiplayerSpawner
	return spawner.spawn({
		"scene_file_path": scene_path,
		"position": position,
		"rotation": rotation,
	})


func safe_is_multiplayer_authority(node : Node) -> bool:
	return node.multiplayer.has_multiplayer_peer() and node.is_multiplayer_authority()


func safe_is_server() -> bool:
	return multiplayer.has_multiplayer_peer() and multiplayer.is_server()


func _process(delta: float) -> void:
	if not multiplayer.has_multiplayer_peer() or not MultiplayerManager.safe_is_server() or multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		return
	if stats_timer.time_left > 0.0:
		return
	stats_timer = get_tree().create_timer(10.0)
	for peer_id in multiplayer.get_peers():
		var peer = multiplayer.multiplayer_peer.get_peer(peer_id)
		if not peer:
			continue
		print("statistics for: '%s' (%d)" % [players[peer_id]["name"], peer_id])
		var ping: float = peer.get_statistic(ENetPacketPeer.PEER_LAST_ROUND_TRIP_TIME)
		var loss: float = peer.get_statistic(ENetPacketPeer.PEER_PACKET_LOSS) / ENetPacketPeer.PACKET_LOSS_SCALE
		print("    ping: ", ping)
		print("    loss: ", loss)

class_name StartGameButton
extends Button

@export var lobby : MultiplayerLobby
@export var character_selector : CharacterSelector


func _ready():
	pressed.connect(_on_button_pressed)


func _on_button_pressed():
	var game_info = {}
	print("trying to start on peers:\n", MultiplayerManager.players)
	MultiplayerManager.start_game_for_peers.rpc(game_info)

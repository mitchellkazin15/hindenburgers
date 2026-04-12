class_name JoinGameButton
extends Button

@export var host_ip_field : TextEdit
@export var name_field : TextEdit
@export var lobby : MultiplayerLobby
var joined = false


func _ready():
	text = "join game"
	button_down.connect(_on_button_pressed)
	MultiplayerManager.server_disconnected.connect(_set_not_joined)


func _on_button_pressed():
	if not joined:
		_set_joined()
	else:
		_set_not_joined()


func _set_joined():
	MultiplayerManager.player_info["name"] = name_field.text
	MultiplayerManager.join_game(host_ip_field.text)
	joined = true
	text = "leave game"
	lobby.show()


func _set_not_joined():
	MultiplayerManager.remove_multiplayer_peer()
	joined = false
	text = "join game"
	lobby.hide()

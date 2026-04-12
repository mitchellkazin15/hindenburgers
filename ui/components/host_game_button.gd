class_name HostGameButton
extends Button

@export var name_field : TextEdit
@export var lobby : MultiplayerLobby
@export var start_game_button : StartGameButton
var hosting = false


func _ready():
	text = "start hosting"
	button_down.connect(_on_button_pressed)


func _on_button_pressed():
	if not hosting:
		MultiplayerManager.player_info["name"] = name_field.text
		MultiplayerManager.host_game()
		hosting = true
		text = "stop hosting"
		lobby.show()
		start_game_button.show()
	else:
		MultiplayerManager.remove_multiplayer_peer()
		hosting = false
		text = "start hosting"
		lobby.hide()
		start_game_button.hide()

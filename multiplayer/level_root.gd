class_name LevelRoot
extends Node2D


func _ready():
	print("loaded level for peer: ", get_multiplayer_authority())
	MultiplayerManager.player_loaded.rpc()

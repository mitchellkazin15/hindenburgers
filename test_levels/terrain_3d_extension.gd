class_name Terrain3DExtension
extends Terrain3D


#func _ready() -> void:
	#if not MultiplayerManager.safe_is_multiplayer_authority(self):
		#var player = EventService.find_player_by_peer(1)
		#if player:
			#print("setting non authority camera")
			#set_camera(player.camera)

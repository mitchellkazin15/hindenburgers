class_name Terrain3DExtension
extends Terrain3D


func _ready() -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		set_physics_process(false)

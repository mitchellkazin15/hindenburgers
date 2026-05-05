class_name Terrain3DExtension
extends Terrain3D


func _ready() -> void:
	set_process(MultiplayerManager.safe_is_multiplayer_authority(self))
	set_physics_process(MultiplayerManager.safe_is_multiplayer_authority(self))
	set_process_input(MultiplayerManager.safe_is_multiplayer_authority(self))

class_name TeleporterUnlockArea3D
extends Area3D

@export var teleporter : Teleporter


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if not MultiplayerManager.safe_is_multiplayer_authority(self):
		return
	if body is Character:
		teleporter.unlocked = true

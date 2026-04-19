class_name AutoSpawner
extends Node3D

@export var spawn_scene : PackedScene


func _ready() -> void:
	if MultiplayerManager.safe_is_server():
		var spawn_node = MultiplayerManager.add_node_to_spawner(spawn_scene.resource_path, self.global_position, self.global_rotation)

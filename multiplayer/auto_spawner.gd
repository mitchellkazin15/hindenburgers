class_name AutoSpawner
extends Node3D

@export var spawn_scene : PackedScene


func _ready() -> void:
	if multiplayer.is_server():
		var spawn_node = spawn_scene.instantiate()
		MultiplayerManager.add_node_to_spawner(spawn_node, self.global_position)

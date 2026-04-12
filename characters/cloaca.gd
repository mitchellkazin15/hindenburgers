class_name Cloaca
extends Node3D

@export var poop_scene : PackedScene
@export var fart_particles : GPUParticles3D


func poop():
	if not is_multiplayer_authority():
		return
	var poop = poop_scene.instantiate()
	MultiplayerManager.add_node_to_spawner(poop, self.global_position)
	show_fart.rpc()


@rpc("any_peer", "call_local", "reliable")
func show_fart():
	if fart_particles:
		fart_particles.restart()

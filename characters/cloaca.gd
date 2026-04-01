class_name Cloaca
extends Node3D

@export var poop_scene : PackedScene
@export var fart_particles : GPUParticles3D


func poop():
	if not is_multiplayer_authority():
		return
	var poop = poop_scene.instantiate()
	var parent_node = $/root/MultiplayerBaseScene/LevelRoot
	parent_node.add_child(poop, true)
	poop.top_level = true
	poop.position = global_position
	show_fart.rpc()


@rpc("any_peer", "call_local", "reliable")
func show_fart():
	if fart_particles:
		fart_particles.restart()

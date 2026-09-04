class_name PaUnit
extends Node3D

@export var button : ButtonArea3D
@export var audio_player : AudioStreamPlayer3D
@export var listen_range = 50.0

var sync_stream : AudioStreamSynchronized
var character_indices : Dictionary[Character, int] = {}


func _ready() -> void:
	sync_stream = audio_player.stream
	PaSystemManager.register_pa_unit(self)


func _physics_process(delta: float) -> void:
	if not button.is_pressed:
		return
	for node in get_tree().get_nodes_in_group("players"):
		if not node is Character:
			continue
		var character := node as Character
		if not character in character_indices.keys():
			print("adding new stream")
			character_indices[character] = character_indices.keys().size()
			sync_stream.set_sync_stream(character_indices[character], character.audio_player.stream)
		if character.global_position.distance_to(self.global_position) <= listen_range:
			sync_stream.set_sync_stream_volume(character_indices[character], 0.0)
		else:
			sync_stream.set_sync_stream_volume(character_indices[character], -80.0)

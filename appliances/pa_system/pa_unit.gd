class_name PaUnit
extends Node3D

@export var button : ButtonArea3D
## Settings donor and mount point: per-speaker players copy its bus/attenuation and parent to it.
@export var audio_player : AudioStreamPlayer3D
@export var input_range = 5.0
@export var listen_range = 100.0
## Seconds of voice each per-speaker generator buffers before it starts dropping frames.
## Matches AudioStreamGenerator's default, which the character-side voice path already uses.
@export var voice_buffer_length = 0.5

var _speaker_players : Dictionary[int, AudioStreamPlayer3D] = {}


func _ready() -> void:
	PaSystemManager.register_pa_unit(self)


func _exit_tree() -> void:
	PaSystemManager.unregister_pa_unit(self)


## The button only arms this unit as a microphone. Playback is unconditional.
func is_broadcasting() -> bool:
	return button.is_pressed


func covers_output(world_position : Vector3) -> bool:
	return global_position.distance_to(world_position) <= listen_range


func covers_input(world_position : Vector3) -> bool:
	return global_position.distance_to(world_position) <= input_range


## Plays one speaker's voice out of this unit, spinning up their player on first use.
func push_voice(speaker_id : int, frames : PackedVector2Array, mix_rate : float) -> void:
	var playback := _playback_for(speaker_id, mix_rate)
	if playback == null or not playback.can_push_buffer(frames.size()):
		return
	for frame in frames:
		playback.push_frame(frame)


## Each speaker needs their own generator: a stream resource can't be shared between players,
## since every player instantiates its own (empty) playback from it.
func _playback_for(speaker_id : int, mix_rate : float) -> AudioStreamGeneratorPlayback:
	if _speaker_players.has(speaker_id):
		return _speaker_players[speaker_id].get_stream_playback() as AudioStreamGeneratorPlayback
	var generator := AudioStreamGenerator.new()
	# Must match the sender's rate or the relayed voice comes out pitch-shifted.
	generator.mix_rate = mix_rate
	generator.buffer_length = voice_buffer_length
	var player := AudioStreamPlayer3D.new()
	player.name = "Voice%d" % speaker_id
	player.stream = generator
	player.bus = audio_player.bus
	player.attenuation_model = audio_player.attenuation_model
	player.unit_size = audio_player.unit_size
	player.max_distance = audio_player.max_distance
	player.volume_db = audio_player.volume_db
	player.panning_strength = audio_player.panning_strength
	audio_player.add_child(player)
	player.play()
	_speaker_players[speaker_id] = player
	return player.get_stream_playback() as AudioStreamGeneratorPlayback

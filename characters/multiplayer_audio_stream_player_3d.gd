class_name MultiplayerAudioStreamPlayer3D
extends AudioStreamPlayer3D

## Frames read from the mic capture effect per physics tick, at the engine's native
## capture rate (AudioServer.get_mix_rate()).
@export var buffer_size := 1024

## Sample rate (Hz) voice audio is resampled to before being sent, and the rate the
## receiving AudioStreamGenerator plays it back at. Lower values cut bandwidth (and
## the byte size of every RPC) at the cost of fidelity. Voice stays intelligible well
## below full audio rates (8000-16000 is standard "telephone quality"); this must be
## the same value across every client, since it's what keeps captured and played-back
## audio at the same pitch. This directly replaces the previous bug: the receiver's
## AudioStreamGenerator used to default to 44100 Hz regardless of the sender's actual
## (device-dependent) mic capture rate, so playback ran at the wrong speed and voices
## came out pitch-shifted.
@export var voice_sample_rate := 16000

## Peers whose character is farther than this (in meters) from the speaker are not
## sent this speaker's voice RPCs at all. Without this, every speaking player
## broadcasts to every connected peer regardless of distance, so total voice traffic
## scales roughly with player_count^2. Should be >= the attenuation range the
## megaphone/normal audio is actually audible at, or nearby players will be culled
## from hearing you before the volume drops to silence.
@export var max_voice_distance := 100.0

const PCM16_MAX := 32767.0

var capture : AudioEffectCapture = null
var playback : AudioStreamGeneratorPlayback = null
var _capture_rate : float = 44100.0


func initialize_multiplayer_audio() -> void:
	if MultiplayerManager.safe_is_multiplayer_authority(self):
		#if AudioServer.input_device == "Default":
			#print(AudioServer.get_input_device_list())
			#print("leaving no mic")
			#return
		stream = AudioStreamMicrophone.new()
		bus = &"Record"
		var bus_idx = AudioServer.get_bus_index(bus)
		play()
		# Capture Effect should be set as the very last effect in the "Record" bus in the editor
		capture = AudioServer.get_bus_effect(bus_idx, AudioServer.get_bus_effect_count(bus_idx) - 1)
		_capture_rate = AudioServer.get_mix_rate()
	else:
		var generator := AudioStreamGenerator.new()
		# Pinned explicitly to voice_sample_rate (see the export comment above) instead
		# of left at AudioStreamGenerator's 44100 Hz default.
		generator.mix_rate = voice_sample_rate
		stream = generator
		bus = &"Master"
		play()
		playback = get_stream_playback()


@rpc("any_peer", "call_local", "reliable")
func add_megaphone_effect():
	attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	if not MultiplayerManager.safe_is_multiplayer_authority(self) or capture == null:
		return
	var bus_idx = AudioServer.get_bus_index(bus)
	var lofi : AudioEffectDistortion = AudioServer.get_bus_effect(bus_idx, 0)
	AudioServer.set_bus_mute(bus_idx, false)
	lofi.drive = 0.35
	lofi.pre_gain = 0.0
	lofi.post_gain = 6.0
	var reverb : AudioEffectReverb = AudioServer.get_bus_effect(bus_idx, 1)
	reverb.wet = 0.25


@rpc("any_peer", "call_local", "reliable")
func remove_megaphone_effect():
	attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	if not MultiplayerManager.safe_is_multiplayer_authority(self) or capture == null:
		return
	var bus_idx = AudioServer.get_bus_index(bus)
	var lofi : AudioEffectDistortion = AudioServer.get_bus_effect(bus_idx, 0)
	AudioServer.set_bus_mute(bus_idx, true)
	lofi.drive = 0.0
	lofi.pre_gain = 0.0
	lofi.post_gain = 0.0
	var reverb : AudioEffectReverb = AudioServer.get_bus_effect(bus_idx, 1)
	reverb.wet = 0.0


## pcm16 is mono 16-bit PCM, already resampled to voice_sample_rate by the sender
## (see _to_pcm16 below). Unreliable/ordered: a dropped voice packet is far less
## noticeable than the latency spikes reliable delivery would add when retransmitting.
@rpc("any_peer", "call_remote", "unreliable_ordered")
func send_audio_data(pcm16 : PackedByteArray):
	if playback == null:
		return
	var sample_count := pcm16.size() / 2
	if not playback.can_push_buffer(sample_count):
		return
	for i in range(sample_count):
		var sample := pcm16.decode_s16(i * 2) / PCM16_MAX
		playback.push_frame(Vector2(sample, sample))


func _physics_process(delta: float) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self) or capture == null:
		return
	if not capture.can_get_buffer(buffer_size):
		return
	var buffer := capture.get_buffer(buffer_size)
	var peak := 0.0
	for frame in buffer:
		peak = max(peak, abs(frame.x), abs(frame.y))
	var peak_db := linear_to_db(peak) if peak > 0.0 else -80.0
	if peak_db <= Settings.get_mic_threshold_db():
		return
	var pcm16 := _to_pcm16(buffer)
	for peer_id in _nearby_peer_ids():
		send_audio_data.rpc_id(peer_id, pcm16)


## Mixes the captured stereo buffer to mono, resamples it from the engine's native
## capture rate down to voice_sample_rate, and quantizes it to 16-bit PCM. Versus the
## previous raw stereo 32-bit float buffer this cuts the payload roughly 4x on
## channels/bit-depth alone, plus whatever further reduction voice_sample_rate gives
## on top (e.g. ~16000/44100 ≈ another 2.75x at the default).
func _to_pcm16(buffer : PackedVector2Array) -> PackedByteArray:
	var ratio := voice_sample_rate / _capture_rate
	var out_count := maxi(1, int(buffer.size() * ratio))
	var bytes := PackedByteArray()
	bytes.resize(out_count * 2)
	for i in range(out_count):
		var src_pos := i / ratio
		var idx0 := clampi(int(src_pos), 0, buffer.size() - 1)
		var idx1 := clampi(idx0 + 1, 0, buffer.size() - 1)
		var frac := src_pos - idx0
		var frame : Vector2 = buffer[idx0].lerp(buffer[idx1], frac)
		var mono := clampf((frame.x + frame.y) * 0.5, -1.0, 1.0)
		bytes.encode_s16(i * 2, int(mono * PCM16_MAX))
	return bytes


## IDs of peers whose character is within max_voice_distance of this speaker. Used
## instead of the old blind .rpc() broadcast to every connected peer, which made
## total voice traffic scale with player_count^2.
func _nearby_peer_ids() -> Array[int]:
	var ids : Array[int] = []
	var my_pos := global_position
	var my_id := get_multiplayer_authority()
	for node in get_tree().get_nodes_in_group("players"):
		var character := node as Character
		if character == null or character.initial_multiplayer_authority == my_id:
			continue
		if character.global_position.distance_to(my_pos) <= max_voice_distance:
			ids.append(character.initial_multiplayer_authority)
	return ids

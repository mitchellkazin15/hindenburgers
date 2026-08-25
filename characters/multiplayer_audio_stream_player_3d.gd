class_name MultiplayerAudioStreamPlayer3D
extends AudioStreamPlayer3D

@export var buffer_size = 1024

var capture : AudioEffectCapture = null
var playback : AudioStreamGeneratorPlayback = null


func initialize_multiplayer_audio() -> void:
	if MultiplayerManager.safe_is_multiplayer_authority(self):
		stream = AudioStreamMicrophone.new()
		bus = &"Record"
		var bus_idx = AudioServer.get_bus_index(bus)
		play()
		# Capture Effect should be set as the very last effect in the "Record" bus in the editor
		capture = AudioServer.get_bus_effect(bus_idx, AudioServer.get_bus_effect_count(bus_idx) - 1)
	else:
		stream = AudioStreamGenerator.new()
		bus = &"Master"
		play()
		playback = get_stream_playback()


@rpc("any_peer", "call_local", "reliable")
func add_megaphone_effect():
	if not MultiplayerManager.safe_is_multiplayer_authority(self) or capture == null:
		return
	var bus_idx = AudioServer.get_bus_index(bus)
	var lofi : AudioEffectDistortion = AudioServer.get_bus_effect(bus_idx, 0)
	AudioServer.set_bus_mute(bus_idx, false)
	lofi.drive = 0.75
	lofi.pre_gain = 3.0
	lofi.post_gain = 10.0


@rpc("any_peer", "call_local", "reliable")
func remove_megaphone_effect():
	if not MultiplayerManager.safe_is_multiplayer_authority(self) or capture == null:
		return
	var bus_idx = AudioServer.get_bus_index(bus)
	var lofi : AudioEffectDistortion = AudioServer.get_bus_effect(bus_idx, 0)
	AudioServer.set_bus_mute(bus_idx, true)
	lofi.drive = 0.0
	lofi.pre_gain = 0.0
	lofi.post_gain = 0.0


@rpc("any_peer", "call_remote", "reliable")
func send_audio_data(data : PackedVector2Array):
	if playback == null or not playback.can_push_buffer(buffer_size):
		return
	for i in range(0, buffer_size):
		playback.push_frame(data[i])


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
	if peak_db > Settings.get_mic_threshold_db():
		send_audio_data.rpc(buffer)

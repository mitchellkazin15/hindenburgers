class_name MultiplayerAudioStreamPlayer3D
extends AudioStreamPlayer3D

@export var buffer_size = 1024

var capture : AudioEffectCapture = null
var playback : AudioStreamGeneratorPlayback = null


func initialize_multiplayer_audio() -> void:
	var mics = AudioServer.get_input_device_list()
	print(mics)
	if MultiplayerManager.safe_is_multiplayer_authority(self):
		stream = AudioStreamMicrophone.new()
		bus = &"Record"
		if multiplayer.get_unique_id() > 1:
			print("applying lofi")
			var distortion = AudioEffectDistortion.new()
			distortion.mode = AudioEffectDistortion.MODE_LOFI
			distortion.drive = 1.0
			AudioServer.add_bus_effect(AudioServer.get_bus_index(bus), distortion)
			var distortion2 = AudioEffectDistortion.new()
			distortion2.mode = AudioEffectDistortion.MODE_OVERDRIVE
			distortion2.drive = 1.0
			AudioServer.add_bus_effect(AudioServer.get_bus_index(bus), distortion2)
			
			print(AudioServer.get_bus_effect_count(AudioServer.get_bus_index(bus)))
		play()
		capture = AudioServer.get_bus_effect(AudioServer.get_bus_index(bus), 0)
	else:
		stream = AudioStreamGenerator.new()
		bus = &"Master"
		play()
		playback = get_stream_playback()


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

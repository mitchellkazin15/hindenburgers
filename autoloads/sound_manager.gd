extends Node2D

var bgm_player : AudioStreamPlayer
var bgm_player_base_volume_linear : float


func _ready():
	Settings.new_settings.connect(_on_settings_update)
	process_mode = Node.PROCESS_MODE_ALWAYS


func play_bgm(stream: AudioStream, base_volume_linear: float = 1.0, force_restart: bool = false):
	if not bgm_player:
		bgm_player = AudioStreamPlayer.new()
		add_child(bgm_player)
	bgm_player_base_volume_linear = base_volume_linear
	bgm_player.volume_db = Settings.get_true_music_volume_db(bgm_player_base_volume_linear)
	if stream == bgm_player.stream and not force_restart:
		return
	bgm_player.autoplay = true
	bgm_player.stream = stream
	if force_restart:
		bgm_player.finished.connect(_loop_bgm)
	bgm_player.play()


func stop_bgm():
	if not bgm_player:
		print("Tried to stop BGM when no BGM player exists.")
		return
	bgm_player.stop()


func _loop_bgm():
	bgm_player.play()


func play_sfx(owner: Node2D, stream: AudioStream, base_volume_linear: float = 1.0, max_distance: float = 1e100, random_pitch_shift = 0.0):
	var instance = AudioStreamPlayer3D.new()
	instance.stream = stream
	instance.finished.connect(remove_node.bind(instance))
	instance.volume_db = Settings.get_true_sfx_volume_db(base_volume_linear)
	instance.max_distance = max_distance
	instance.pitch_scale = 1.0 + randf_range(-random_pitch_shift, random_pitch_shift)
	owner.add_child(instance)
	instance.play()


func remove_node(instance: AudioStreamPlayer3D):
	instance.queue_free()


func _on_settings_update(settings : SettingsFile):
	if not bgm_player:
		return
	bgm_player.volume_db = Settings.get_true_music_volume_db(bgm_player_base_volume_linear)

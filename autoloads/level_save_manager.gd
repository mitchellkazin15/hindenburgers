extends Node

const SAVED_LEVEL_FILE_PATH = SavePaths.LEVEL
const SAVED_BASE_LEVEL_FILE_PATH = SavePaths.BASE_LEVEL

@export var auto_save_interval = 33.33
## Turn off while hand-editing a save file, so a background instance cannot write
## over the edit before the next run reads it.
@export var auto_save_enabled = true

var auto_save_timer : SceneTreeTimer
var base_level_saved = false
## False until load_level() has actually put a level in LevelRoot this session.
## Guards save_level() - see the comment there.
var level_loaded = false


func _ready() -> void:
	auto_save_timer = get_tree().create_timer(0.0)
	SavePaths.ensure_dir()


func save_level():
	if not MultiplayerManager.safe_is_server():
		return
	# Refuse to write before a level has been loaded. Whatever is in memory right now is
	# either nothing or debris from a previous session, and writing it would destroy the
	# save on disk before load_level() ever reads it - including any hand edits.
	if not level_loaded:
		print("skipped a level save: no level loaded yet (state=", EventService.state, ")")
		return
	if OS.is_debug_build():
		var stack = get_stack()
		var caller = "?" if stack.size() < 2 else "%s:%d" % [stack[1]["source"], stack[1]["line"]]
		print("saving level from ", caller, " state=", EventService.state,
			" atm=", AtmCoinPurse.money_val,
			" unlocks=", TeleportationManager.generate_unlock_save_dict())
	if not base_level_saved:
		_save_base_level_scene()
		base_level_saved = true
	SavePaths.ensure_dir()
	var level_save = LevelSaveFile.new()
	for body in RigidBodySyncManager.tracked_bodies:
		if not body or not is_instance_valid(body):
			continue
		if body is Character:
			continue
		level_save.rigid_body_states.append([
			body.scene_file_path,
			body.position,
			body.rotation,
	])
	print("saving stuff")
	level_save.atm_money_val = AtmCoinPurse.money_val
	level_save.teleporter_unlocks_dict = TeleportationManager.generate_unlock_save_dict()
	ResourceSaver.save(level_save, SAVED_LEVEL_FILE_PATH)
	print("wrote save ", ProjectSettings.globalize_path(SAVED_LEVEL_FILE_PATH))


## " (last modified Ns ago)" - if this reads as seconds when the edit was made minutes
## ago, something rewrote the file in between. A background instance of the game still
## running is the usual culprit: its auto save fires every auto_save_interval seconds.
func _file_age_note(path : String) -> String:
	if not FileAccess.file_exists(path):
		return " (missing)"
	var age_sec = Time.get_unix_time_from_system() - FileAccess.get_modified_time(path)
	return " (last modified %ds ago)" % int(age_sec)


## Remove any rigid bodies or auto spawners from base_level and load in saved body states
func load_level(game_info : Dictionary):
	if not MultiplayerManager.safe_is_server():
		return
	print("loading saved level file")
	var load_started_ms = Time.get_ticks_msec()
	SavePaths.ensure_dir()
	var spawner : BetterMultiplayerSpawner = $/root/Main/MultiplayerBaseScene/MultiplayerSpawner
	if game_info["new_game"] or not FileAccess.file_exists(SAVED_BASE_LEVEL_FILE_PATH) or not FileAccess.file_exists(SAVED_LEVEL_FILE_PATH):
		spawner.spawn({
			"scene_file_path": "res://test_levels/terrain_level.scn",
		})
		level_loaded = true
		return
	var saved_level : LevelSaveFile = ResourceLoader.load(SAVED_LEVEL_FILE_PATH, "LevelSaveFile", 0)
	print("read save ", ProjectSettings.globalize_path(SAVED_LEVEL_FILE_PATH),
		" atm=", saved_level.atm_money_val,
		" unlocks=", saved_level.teleporter_unlocks_dict,
		" bodies=", saved_level.rigid_body_states.size(),
		_file_age_note(SAVED_LEVEL_FILE_PATH))
	var saved_base_level = MultiplayerManager.add_node_to_spawner(SAVED_BASE_LEVEL_FILE_PATH, Vector3.ZERO)
	for body in saved_level.rigid_body_states:
		MultiplayerManager.add_node_to_spawner(
			body[LevelSaveFile.StateIndices.SCENE_PATH],
			body[LevelSaveFile.StateIndices.POS],
			body[LevelSaveFile.StateIndices.ROT],
		)
	print("loading stuff")
	print(saved_level)
	print(saved_level.atm_money_val)
	print(saved_level.teleporter_unlocks_dict)
	AtmCoinPurse.money_val = saved_level.atm_money_val
	TeleportationManager.load_teleporter_unlocks(saved_level.teleporter_unlocks_dict)
	# The level we just spawned came straight out of SAVED_BASE_LEVEL_FILE_PATH, so it
	# is already on disk and repacking it here would only rewrite it. That matters:
	# add_node_to_spawner() above told every connected peer to load that same path, and
	# BetterMultiplayerSpawner._custom_spawn_func streams it rather than reading it in
	# one go. Rewriting it underneath them truncates the file mid-parse.
	base_level_saved = true
	level_loaded = true
	save_level()
	# This whole function runs on the main thread in one go. Anything past a couple of
	# seconds and ENet on the other end starts treating the host as gone, so it is worth
	# knowing how long it actually took. See MultiplayerManager.PEER_TIMEOUT_MIN_MS.
	var load_elapsed_ms = Time.get_ticks_msec() - load_started_ms
	print("level load blocked the host for ", load_elapsed_ms, " ms")
	if load_elapsed_ms > 2000:
		push_warning("level load blocked the main thread for %d ms" % load_elapsed_ms)


func _save_base_level_scene():
	var pack_started_ms = Time.get_ticks_msec()
	SavePaths.ensure_dir()
	var level_scene = PackedScene.new()
	var level_node = $/root/Main/MultiplayerBaseScene/LevelRoot/Level.duplicate()
	for child in level_node.find_children("*"):
		if child is AutoSpawner or child is RelativeRigidBody3D:
			if child is Customer:
				continue
			child.get_parent().remove_child(child)
	_strip_generated_terrain_textures(level_node)
	level_scene.pack(level_node)
	# Write somewhere else and swap it in, so a peer part way through parsing the
	# previous file never sees this one truncate it.
	if ResourceSaver.save(level_scene, SavePaths.BASE_LEVEL_TMP) != OK:
		push_error("could not write base level scene")
		return
	var rename_error = DirAccess.rename_absolute(SavePaths.BASE_LEVEL_TMP, SAVED_BASE_LEVEL_FILE_PATH)
	if rename_error != OK:
		push_error("could not swap base level scene into place: %d" % rename_error)
		return
	var written = FileAccess.open(SAVED_BASE_LEVEL_FILE_PATH, FileAccess.READ)
	var written_kib = 0 if written == null else written.get_length() / 1024
	print("packed base level in ", Time.get_ticks_msec() - pack_started_ms, " ms (", written_kib, " KiB)")


## Terrain3D builds a normal map ImageTexture for every texture asset that has no
## normal map on disk, and this project ships _Color.png files only. Those textures
## have no resource_path, so PackedScene.pack() writes them into the scene inline -
## four 1024x1024 DXT5 blobs, around 26 MB of text in a file peers have to parse
## over the network path. It is derived data that Terrain3D rebuilds on load, so
## drop it from the copy being packed. The assets resource is shared with the live
## terrain, hence the duplicate() calls - clearing it in place would strip the
## normal maps off the running game.
func _strip_generated_terrain_textures(level_node : Node) -> void:
	for child in level_node.find_children("*"):
		if not (child is Terrain3D):
			continue
		if child.assets == null:
			continue
		var assets : Terrain3DAssets = child.assets.duplicate()
		var textures : Array[Terrain3DTextureAsset] = []
		for texture_asset in assets.texture_list:
			if texture_asset == null:
				textures.append(null)
				continue
			var texture_copy : Terrain3DTextureAsset = texture_asset.duplicate()
			if texture_copy.normal_texture and texture_copy.normal_texture.resource_path.is_empty():
				texture_copy.normal_texture = null
			textures.append(texture_copy)
		assets.texture_list = textures
		child.assets = assets


func _physics_process(delta: float) -> void:
	if (not multiplayer.has_multiplayer_peer() 
		or not MultiplayerManager.safe_is_server() 
		or auto_save_timer.time_left != 0.0 
		or EventService.state != EventService.GameState.IN_GAME
		or not auto_save_enabled
	):
		return
	print("auto saving")
	save_level()
	auto_save_timer = get_tree().create_timer(auto_save_interval)

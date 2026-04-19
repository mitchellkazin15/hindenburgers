extends Node

const SAVED_LEVEL_FILE_PATH = "res://save_files/level_save_file.tres"
const SAVED_BASE_LEVEL_FILE_PATH = "res://save_files/base_level.tscn"

@export var auto_save_interval = 33.33

var auto_save_timer : SceneTreeTimer
var base_level_saved = false


func _ready() -> void:
	auto_save_timer = get_tree().create_timer(0.0)


func save_level():
	if not MultiplayerManager.safe_is_server():
		return
	if not base_level_saved:
		_save_base_level_scene()
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
	for child in $/root/Main/MultiplayerBaseScene/LevelRoot/Level.find_children("*Atm*"):
		if child is Atm:
			var atm : Atm = child
			level_save.atm_money_vals[atm.get_path()] = atm.vault.money_val
	ResourceSaver.save(level_save, SAVED_LEVEL_FILE_PATH)


## Remove any rigid bodies or auto spawners from base_level and load in saved body states
func load_level():
	if not MultiplayerManager.safe_is_server():
		return
	print("loading saved level file")
	var res_dir = DirAccess.open("res://")
	var spawner : BetterMultiplayerSpawner = $/root/Main/MultiplayerBaseScene/MultiplayerSpawner
	if not res_dir.file_exists(SAVED_BASE_LEVEL_FILE_PATH) or not res_dir.file_exists(SAVED_LEVEL_FILE_PATH):
		spawner.spawn({
			"scene_file_path": "res://test_levels/level.tscn",
		})
		return
	var saved_base_level = MultiplayerManager.add_node_to_spawner(SAVED_BASE_LEVEL_FILE_PATH, Vector3.ZERO)
	var saved_level : LevelSaveFile = ResourceLoader.load(SAVED_LEVEL_FILE_PATH, "LevelSaveFile", 0)
	for body in saved_level.rigid_body_states:
		MultiplayerManager.add_node_to_spawner(
			body[LevelSaveFile.StateIndices.SCENE_PATH],
			body[LevelSaveFile.StateIndices.POS],
			body[LevelSaveFile.StateIndices.ROT],
		)
	for atm_path in saved_level.atm_money_vals.keys():
		var atm : Atm = get_node(atm_path)
		atm.vault.money_val = saved_level.atm_money_vals[atm_path]


func _save_base_level_scene():
	var level_scene = PackedScene.new()
	var level_node = $/root/Main/MultiplayerBaseScene/LevelRoot/Level.duplicate()
	for child in level_node.find_children("*"):
		if child is AutoSpawner or child is RelativeRigidBody3D:
			if child is Customer:
				continue
			child.get_parent().remove_child(child)
	level_scene.pack(level_node)
	ResourceSaver.save(level_scene, SAVED_BASE_LEVEL_FILE_PATH)


func _physics_process(delta: float) -> void:
	if (not multiplayer.has_multiplayer_peer() 
		or not MultiplayerManager.safe_is_server() 
		or auto_save_timer.time_left != 0.0 
		or EventService.state != EventService.GameState.IN_GAME
	):
		return
	save_level()
	auto_save_timer = get_tree().create_timer(auto_save_interval)

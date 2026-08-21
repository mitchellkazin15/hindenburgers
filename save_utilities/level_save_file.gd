class_name LevelSaveFile
extends Resource

enum StateIndices {SCENE_PATH = 0, POS = 1, ROT = 2}

## Each entry is an array with 3 ectries [scene_path, position, rotation]
@export var rigid_body_states : Array[Array] = []
@export var atm_money_val = 0.0
## Dict of teleporter index to bool (true = teleporter unlocked)
@export var teleporter_unlocks_dict : Dictionary[int, bool]

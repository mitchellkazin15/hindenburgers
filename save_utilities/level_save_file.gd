class_name LevelSaveFile
extends Resource

enum StateIndices {SCENE_PATH = 0, POS = 1, ROT = 2}

## Each entry is an array with 3 ectries [scene_path, position, rotation]
@export var rigid_body_states : Array[Array] = []
## Dict of Atm node_path to its current money val
@export var atm_money_vals = {}

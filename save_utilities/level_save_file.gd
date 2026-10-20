class_name LevelSaveFile
extends Resource

## 2: customers are saved as rigid bodies and are not in the base level scene.
## Files without this field are version 1, which had customers in both places.
const FORMAT_VERSION := 2
@export var format_version := 1

enum StateIndices {SCENE_PATH = 0, POS = 1, ROT = 2, STACK_DATA = 3}

## Each entry is an array with 3 ectries [scene_path, position, rotation]
## Stacked items have a 4th entry [stacked_scenes, stacked_scene_positions, stacked_scene_rotations, stacked_states]
@export var rigid_body_states : Array[Array] = []
@export var atm_money_val = 0.0
## Dict of teleporter index to bool (true = teleporter unlocked)
@export var teleporter_unlocks_dict : Dictionary[int, bool]

class_name CharacterStatManager
extends StatManager

const EXAMPLE_DICT = { # Do NOT update values in this script and expect stats to change in game
	"speed": 0.0,
	"jump_impulse": 0.0,
	"sprint_multiplier": 0.0,
	"air_acceleration": 0.0,
} 

## Dict of stat_name -> base val.
@export var base_stats = EXAMPLE_DICT


func _ready():
	_base_stats = base_stats
	super._ready()


func get_current_speed():
	return _get_modified_stat("speed")


func get_current_jump_impulse():
	return _get_modified_stat("jump_impulse")


func get_current_sprint_multiplier():
	return _get_modified_stat("sprint_multiplier")


func get_current_air_acceleration():
	return _get_modified_stat("air_acceleration")

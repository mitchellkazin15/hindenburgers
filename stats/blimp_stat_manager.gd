class_name BlimpStatManager
extends StatManager

const EXAMPLE_DICT = { # Do NOT update values in this script and expect stats to change in game
	"max_speed": 0.0,
	"acceleration": 0.0,
	"rising_acceleration": 0.0,
	"boost_acceleration_multiplier": 0.0,
	"rotational_torque_scalar": 0.0,
	"righting_torque_scalar": 0.0
} 

## Dict of stat_name -> base val.
@export var base_stats = EXAMPLE_DICT


func _ready():
	_base_stats = base_stats
	super._ready()


func get_current_max_speed():
	return _get_modified_stat("max_speed")


func get_current_acceleration():
	return _get_modified_stat("acceleration")


func get_current_rising_acceleration():
	return _get_modified_stat("rising_acceleration")


func get_current_boost_acceleration_multiplier():
	return _get_modified_stat("boost_acceleration_multiplier")


func get_current_rotational_torque_scalar():
	return _get_modified_stat("rotational_torque_scalar")


func get_current_righting_torque_scalar():
	return _get_modified_stat("righting_torque_scalar")

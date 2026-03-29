class_name DrugVisualEffectStatManager
extends StatManager

const EXAMPLE_DICT = { # Do NOT update values in this script and expect stats to change in game
	"x_wiggle_amp": 0.0,
	"x_wiggle_screen_freq": 0.0,
	"x_wiggle_time_freq": 0.0,
	"y_wiggle_amp": 0.0,
	"y_wiggle_screen_freq": 0.0,
	"y_wiggle_time_freq": 0.0,
	"brightness": 0.0,
	"contrast": 0.0,
	"saturation": 0.0,
	"saturation_color": 0.0
} 

## Dict of stat_name -> base val.
@export var base_stats = EXAMPLE_DICT


func _ready():
	_base_stats = base_stats
	super._ready()

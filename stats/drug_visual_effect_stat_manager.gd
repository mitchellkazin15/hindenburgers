class_name DrugVisualEffectStatManager
extends StatManager

const EXAMPLE_DICT = { # Do NOT update values in this script and expect stats to change in game
	"x_wiggle_amp": 0.0,
	"x_wiggle_screen_freq": 0.0,
	"x_wiggle_time_freq": 0.0,
	"y_wiggle_amp": 0.0,
	"y_wiggle_screen_freq": 0.0,
	"y_wiggle_time_freq": 0.0,
	"blur_iterations": 0.0,
	"blur_power": 0.0,
	"brightness": 0.0,
	"contrast": 0.0,
	"saturation": 0.0,
	"saturation_color": 0.0,
	"fractal_noise_distortion": 0.0,
	"fractal_noise_iterations": 0.0,
	"fractal_noise_overlay_strength": 0.0,
	"fractal_chromatic_shift_strength": 0.0,
	"fractal_ping_pong_strength_amplitude": 0.0,
	"fractal_lacunarity_amplitude": 0.0,
	"fractal_gain_amplitude": 0.0,
	"fractal_ping_pong_strength_frequency": 0.0,
	"fractal_lacunarity_frequency": 0.0,
	"fractal_gain_frequency": 0.0
}

const SHADER_PARAMS_NAMES = [
	"x_wiggle_amp",
	"x_wiggle_screen_freq",
	"x_wiggle_time_freq",
	"y_wiggle_amp",
	"y_wiggle_screen_freq",
	"y_wiggle_time_freq",
	"blur_iterations",
	"blur_power",
	"brightness",
	"contrast",
	"saturation",
	"saturation_color",
	"fractal_noise_distortion",
	"fractal_noise_iterations",
	"fractal_noise_overlay_strength",
	"fractal_chromatic_shift_strength"
]

## Dict of stat_name -> base val.
@export var base_stats = EXAMPLE_DICT


func _ready():
	_base_stats = base_stats
	super._ready()


func get_current_fractal_ping_pong_strength_amplitude():
	return _get_modified_stat("fractal_ping_pong_strength_amplitude")


func get_current_fractal_lacunarity_amplitude():
	return _get_modified_stat("fractal_lacunarity_amplitude")


func get_current_fractal_gain_amplitude():
	return _get_modified_stat("fractal_gain_amplitude")


func get_current_fractal_ping_pong_strength_frequency():
	return _get_modified_stat("fractal_ping_pong_strength_frequency")


func get_current_fractal_lacunarity_frequency():
	return _get_modified_stat("fractal_lacunarity_frequency")


func get_current_fractal_gain_frequency():
	return _get_modified_stat("fractal_gain_frequency")

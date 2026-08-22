class_name DrugManager
extends Node3D

@export var character_stats : CharacterStatManager
@export var visual_stats : DrugVisualEffectStatManager

@onready var history_a := $SubViewportA
@onready var history_b := $SubViewportB
var use_a = true

var shader : ShaderMaterial
var fractal_noise_texture : NoiseTexture2D
var fractal_noise : FastNoiseLite

var noise_update_interval := 0.05
var _accum := 0.0
var total_accum = 0.0

const TRAIL_REFERENCE_FPS := 30.0
var _trail_amount := 0.0


func _ready() -> void:
	shader = $CanvasLayer/ColorRect.material
	fractal_noise_texture = shader.get_shader_parameter("fractal_noise_texture")
	fractal_noise = fractal_noise_texture.noise
	visual_stats.stat_updated.connect(_on_visual_stat_update)
	for stat_name in visual_stats.base_stats.keys():
		_on_visual_stat_update(stat_name)


@rpc("any_peer", "call_local", "reliable")
func clear_drug_visual_effects():
	visual_stats.clear_all_temp_stats()


@rpc("any_peer", "call_local", "reliable")
func apply_drug_visual_effects(stat_adders, stat_multipliers, effect_duration):
	visual_stats.register_all_temp_adders(stat_adders, effect_duration)
	visual_stats.register_all_temp_multipliers(stat_multipliers, effect_duration)


func apply_drug_character_effects(stat_adders, stat_multipliers, effect_duration):
	character_stats.register_all_temp_adders(stat_adders, effect_duration)
	character_stats.register_all_temp_multipliers(stat_multipliers, effect_duration)


func _on_visual_stat_update(stat_name : String):
	var curr_stat = visual_stats._get_modified_stat(stat_name)
	if stat_name == "saturation_color":
		# Color needs to be handled differently
		var float_color = curr_stat
		var int_color = int(float_color)
		shader.set_shader_parameter(stat_name, Color(int_color))
	elif stat_name == "trail_amount":
		_trail_amount = clampf(curr_stat, 0.0, 0.99)
	elif stat_name in DrugVisualEffectStatManager.SHADER_PARAMS_NAMES:
		shader.set_shader_parameter(stat_name, curr_stat)


func _process(delta):
	if not $CanvasLayer.visible:
		return
	_accum += delta
	total_accum += delta
	if _accum >= noise_update_interval:
		_accum -= noise_update_interval
		_update_noise_params()
	history_a.size = get_viewport().size
	history_b.size = get_viewport().size
	var read_from := history_b if use_a else history_a
	var write_to := history_a if use_a else history_b
	shader.set_shader_parameter("history_tex", read_from.get_texture())
	# a = k^delta keeps a^frames dependent on elapsed time only. maxf() guards a
	# zero delta, which would give pow(x, 0) == 1.0 and freeze the frame for a tick.
	shader.set_shader_parameter("trail_amount",
		pow(_trail_amount, maxf(delta, 0.0001) * TRAIL_REFERENCE_FPS))
	# write_to holds a copy of the finished frame, read back as history next frame.
	write_to.get_node("ColorRect").material.set_shader_parameter("source", get_viewport().get_texture())
	use_a = !use_a


func _update_noise_params():
	fractal_noise.fractal_ping_pong_strength = (6.0 + 
		visual_stats.get_current_fractal_ping_pong_strength_amplitude() * 
		sin(TAU * total_accum * visual_stats.get_current_fractal_ping_pong_strength_frequency())
	)
	fractal_noise.fractal_lacunarity = (5 + 
		visual_stats.get_current_fractal_lacunarity_amplitude() * 
		sin(TAU * total_accum * visual_stats.get_current_fractal_lacunarity_frequency())
	)
	fractal_noise.fractal_gain = (0.7 + 
		visual_stats.get_current_fractal_gain_amplitude() * 
		sin(TAU * total_accum * visual_stats.get_current_fractal_gain_frequency())
	)

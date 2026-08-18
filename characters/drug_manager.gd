class_name DrugManager
extends Node3D

@export var character_stats : CharacterStatManager
@export var visual_stats : DrugVisualEffectStatManager

var shader : ShaderMaterial
var fractal_noise_texture : NoiseTexture2D
var fractal_noise : FastNoiseLite

var noise_update_interval := 0.25  # regenerate ~10x/sec instead of 60x/sec
var _accum := 0.0
var noise_updates = 0.0


func _ready() -> void:
	shader = $DrugScreenEffectQuad.material_override
	fractal_noise_texture = shader.get_shader_parameter("fractal_noise_texture")
	fractal_noise = fractal_noise_texture.noise
	visual_stats.stat_updated.connect(_on_visual_stat_update)
	# Call once on startup to set base values
	_on_visual_stat_update("")


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


func _on_visual_stat_update(stat_name):
	var curr_stat = visual_stats._get_modified_stat(stat_name)
	if stat_name == "saturation_color":
		# Color needs to be handled differently
		var float_color = curr_stat
		var int_color = int(float_color)
		shader.set_shader_parameter(stat_name, Color(int_color))
		return
	shader.set_shader_parameter(stat_name, curr_stat)


func _process(delta):
	_accum += delta
	if _accum >= noise_update_interval:
		_accum -= noise_update_interval
		noise_updates += 1.0
		_update_noise_params()

func _update_noise_params():
	fractal_noise.fractal_ping_pong_strength = 6.0 + 4.0 * sin(TAU * noise_updates / 200.0)
	fractal_noise.fractal_lacunarity = 2 + 1.0 * sin(TAU * noise_updates / 100.0)
	fractal_noise.fractal_gain = 0.5 + 0.4 * sin(TAU * noise_updates / 500.0)

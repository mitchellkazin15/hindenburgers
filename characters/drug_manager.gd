class_name DrugManager
extends Node3D

@export var character_stats : CharacterStatManager
@export var visual_stats : DrugVisualEffectStatManager

var shader : ShaderMaterial


func _ready() -> void:
	shader = $DrugScreenEffectQuad.material_override
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

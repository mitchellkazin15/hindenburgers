class_name TemporaryCharacterStatEffect
extends ItemEffect

@export var effect_duration = 0.0
@export var stat_adders = CharacterStatManager.EXAMPLE_DICT
@export var stat_multipliers = CharacterStatManager.EXAMPLE_DICT


func apply_effect(user : Node3D, _use_charge_time : float):
	var stats = user.get("stats")
	if stats is CharacterStatManager:
		stats.register_all_temp_adders(stat_adders, effect_duration)
		stats.register_all_temp_multipliers(stat_multipliers, effect_duration)

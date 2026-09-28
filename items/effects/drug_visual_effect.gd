class_name DrugVisualEffect
extends ItemEffect

@export var effect_duration = 0.0
@export var stat_adders = DrugVisualEffectStatManager.EXAMPLE_DICT
@export var stat_multipliers = DrugVisualEffectStatManager.EXAMPLE_DICT


func apply_effect(user : Node3D, _use_charge_time : float):
	if user.has_node("DrugManager"):
		var drug_manager : DrugManager = user.get_node("DrugManager")
		drug_manager.apply_drug_visual_effects.rpc(stat_adders, stat_multipliers, effect_duration)

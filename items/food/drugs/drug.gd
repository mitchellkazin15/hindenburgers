class_name Drug
extends EdibleItem

@export var drug_effect_duration = 0.0
@export var drug_visual_effect_adders = DrugVisualEffectStatManager.EXAMPLE_DICT
@export var drug_visual_effect_multipliers = DrugVisualEffectStatManager.EXAMPLE_DICT
@export var drug_character_effect_adders = CharacterStatManager.EXAMPLE_DICT
@export var drug_character_effect_multipliers = CharacterStatManager.EXAMPLE_DICT


func use(use_charge_time : float):
	if use_charge_time < max_use_charge_time:
		return
	if item_holder.has_node("DrugManager"):
		var drug_manager : DrugManager = item_holder.get_node("DrugManager")
		drug_manager.apply_drug_visual_effects.rpc(drug_visual_effect_adders, drug_visual_effect_multipliers, drug_effect_duration)
		drug_manager.apply_drug_character_effects(drug_character_effect_adders, drug_character_effect_multipliers, drug_effect_duration)
	# new effects first, then call super
	super.use(use_charge_time)

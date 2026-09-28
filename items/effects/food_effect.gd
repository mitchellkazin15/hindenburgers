class_name FoodEffect
extends ItemEffect

@export var food_val = 10.0


func can_apply(user : Node3D, use_charge_time : float) -> bool:
	if not super.can_apply(user, use_charge_time) or not user.has_node("Stomach"):
		return false
	var stomach : Stomach = user.get_node("Stomach")
	return not stomach.is_full()


func apply_effect(user : Node3D, _use_charge_time : float):
	var stomach : Stomach = user.get_node("Stomach")
	stomach.add_food.rpc(food_val)

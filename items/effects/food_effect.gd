class_name FoodEffect
extends ItemEffect

@export var food_val = 10.0


func apply_effect(user : Node3D, _use_charge_time : float):
	if user.has_node("Stomach"):
		var stomach : Stomach = user.get_node("Stomach")
		stomach.add_food.rpc(food_val)

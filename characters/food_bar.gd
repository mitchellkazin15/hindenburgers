class_name FoodBar
extends TextureProgressBar

@export var stomach : Stomach
@export var high_food_bar : Texture2D
@export var mid_food_bar : Texture2D
@export var low_food_bar : Texture2D
@export var max_mid_food_ratio = .5
@export var max_low_food_ratio = .25
@export var initialize = false

var initial_scale


func _physics_process(delta: float) -> void:
	var food_ratio = stomach._curr_food_val / stomach.max_food_capacity
	if food_ratio > max_mid_food_ratio:
		texture_progress = high_food_bar
	elif food_ratio > max_low_food_ratio:
		texture_progress = mid_food_bar
	else:
		texture_progress = low_food_bar
	value = max_value * food_ratio

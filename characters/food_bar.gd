class_name FoodBar
extends TextureProgressBar

#@export var food_component : foodComponent
@export var stomach : Stomach
@export var high_food_bar : Texture2D
@export var mid_food_bar : Texture2D
@export var low_food_bar : Texture2D
@export var max_mid_food_ratio = .5
@export var max_low_food_ratio = .25
@export var initialize = false

var initial_scale


func _ready():
	#if not food_component and TreeUtilities.has_parent_of_name("PoolHud", self):
		#food_component = TreeUtilities.get_parent_of_name("PoolHud", self).food_component
	#if not food_component.is_node_ready():
		#await food_component.ready
	#food_component.food_update.connect(_on_food_update)
	#if initialize:
		#_on_food_update(food_component.current_food, food_component._get_current_full_food(), 0.0)
	pass


func _physics_process(delta: float) -> void:
	var food_ratio = stomach._curr_food_val / stomach.max_food_capacity
	if food_ratio > max_mid_food_ratio:
		texture_progress = high_food_bar
	elif food_ratio > max_low_food_ratio:
		texture_progress = mid_food_bar
	else:
		texture_progress = low_food_bar
	value = max_value * food_ratio
	


func _on_food_update(current_food, base_food, _food_diff):
	#$Label.text = "%d/%d" % [current_food, base_food]
	var food_ratio = current_food / base_food
	if food_ratio > max_mid_food_ratio:
		texture_progress = high_food_bar
	elif food_ratio > max_low_food_ratio:
		texture_progress = mid_food_bar
	else:
		texture_progress = low_food_bar
	value = max_value * food_ratio

class_name PoopBar
extends TextureProgressBar

#@export var poop_component : poopComponent
@export var colon : Colon
@export var high_poop_bar : Texture2D
@export var mid_poop_bar : Texture2D
@export var low_poop_bar : Texture2D
@export var max_mid_poop_ratio = .5
@export var max_low_poop_ratio = .25
@export var initialize = false

var initial_scale


func _ready():
	#if not poop_component and TreeUtilities.has_parent_of_name("PoolHud", self):
		#poop_component = TreeUtilities.get_parent_of_name("PoolHud", self).poop_component
	#if not poop_component.is_node_ready():
		#await poop_component.ready
	#poop_component.poop_update.connect(_on_poop_update)
	#if initialize:
		#_on_poop_update(poop_component.current_poop, poop_component._get_current_full_poop(), 0.0)
	pass


func _physics_process(delta: float) -> void:
	var poop_ratio = colon._curr_digested_food_val / colon.max_digested_food_capacity
	if poop_ratio > max_mid_poop_ratio:
		texture_progress = high_poop_bar
	elif poop_ratio > max_low_poop_ratio:
		texture_progress = mid_poop_bar
	else:
		texture_progress = low_poop_bar
	value = max_value * poop_ratio
	


func _on_poop_update(current_poop, base_poop, _poop_diff):
	#$Label.text = "%d/%d" % [current_poop, base_poop]
	var poop_ratio = current_poop / base_poop
	if poop_ratio > max_mid_poop_ratio:
		texture_progress = high_poop_bar
	elif poop_ratio > max_low_poop_ratio:
		texture_progress = mid_poop_bar
	else:
		texture_progress = low_poop_bar
	value = max_value * poop_ratio

class_name HealthBar
extends TextureProgressBar

@export var health_component : HealthComponent
@export var high_health_bar : Texture2D
@export var mid_health_bar : Texture2D
@export var low_health_bar : Texture2D
@export var max_mid_health_ratio = .5
@export var max_low_health_ratio = .25
@export var initialize = false

var initial_scale


func _physics_process(delta: float) -> void:
	var health_ratio = health_component.current_health / health_component._get_current_full_health()
	if health_ratio > max_mid_health_ratio:
		texture_progress = high_health_bar
	elif health_ratio > max_low_health_ratio:
		texture_progress = mid_health_bar
	else:
		texture_progress = low_health_bar
	value = max_value * health_ratio

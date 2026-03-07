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


func _ready():
	if not health_component and TreeUtilities.has_parent_of_name("PoolHud", self):
		health_component = TreeUtilities.get_parent_of_name("PoolHud", self).health_component
	if not health_component.is_node_ready():
		await health_component.ready
	health_component.health_update.connect(_on_health_update)
	if initialize:
		_on_health_update(health_component.current_health, health_component._get_current_full_health(), 0.0)


func _on_health_update(current_health, base_health, _health_diff):
	$Label.text = "%d/%d" % [current_health, base_health]
	var health_ratio = current_health / base_health
	if health_ratio > max_mid_health_ratio:
		texture_progress = high_health_bar
	elif health_ratio > max_low_health_ratio:
		texture_progress = mid_health_bar
	else:
		texture_progress = low_health_bar
	value = max_value * health_ratio

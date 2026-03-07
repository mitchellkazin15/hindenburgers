class_name ExpLabel
extends Label

@export var experience_component : ExperienceComponent


func _ready():
	experience_component.experience_update.connect(_on_experience_update)
	experience_component.level_update.connect(_on_experience_update)
	if not experience_component.is_node_ready():
		await experience_component.ready
	_on_experience_update(experience_component.experience)


func _on_experience_update(_unused):
	var experience = experience_component.experience
	var level = experience_component.level
	var last_level_threshold = experience_component._get_exp_threshold(level - 1)
	text = "Lvl. %d\n%1.2f/%1.2f" % [
		level,
		experience - last_level_threshold,
		experience_component._get_exp_threshold(level) - last_level_threshold,
	]

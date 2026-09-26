class_name Mouth
extends MeshInstance3D

@export var scale_change_speed = 1.0
@export var max_mouth_open_scale = 1.5

var base_mouth_open_scale : float


func _ready() -> void:
	base_mouth_open_scale = scale.z


func set_mouth_open(speaking_power_db):
	var linear_power = db_to_linear(speaking_power_db)
	var speaking_strength = base_mouth_open_scale + linear_power * max_mouth_open_scale
	scale.z = clamp(speaking_strength, base_mouth_open_scale, max_mouth_open_scale)


func _physics_process(delta: float) -> void:
	if scale.z == base_mouth_open_scale:
		return
	scale.z = max(base_mouth_open_scale, scale.z - scale_change_speed * delta)

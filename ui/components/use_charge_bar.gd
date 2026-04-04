class_name UseChargeBar
extends Control

@export var character : Character
@export var progress_bar : TextureProgressBar
@export var icon : Sprite2D
@export var eat_texture : Texture2D
@export var other_use_texture : Texture2D


func _process(delta: float) -> void:
	if not character.held_item:
		progress_bar.value = 0.0
		return
	if character.held_item is EdibleItem:
		icon.texture = eat_texture
	else:
		icon.texture = other_use_texture
	var max_charge = character.held_item.max_use_charge_time
	var curr_charge = character.use_item_stopwatch.time_elapsed_sec
	progress_bar.value = 100.0 * min(curr_charge, max_charge) / max_charge

class_name ThrowChargeBar
extends Control

@export var character : Character
@export var progress_bar : TextureProgressBar


func _process(delta: float) -> void:
	var max_charge = character.stats.get_current_max_throw_charge_time()
	var curr_charge = character.throw_item_stopwatch.time_elapsed_sec
	progress_bar.value = 100.0 * min(curr_charge, max_charge) / max_charge

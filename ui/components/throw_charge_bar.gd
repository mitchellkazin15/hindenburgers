class_name ThrowChargeBar
extends Control

@export var character : Character
@export var progress_bar : TextureProgressBar


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())


func _process(delta: float) -> void:
	if not character.held_item:
		progress_bar.value = 0.0
		return
	var max_charge = character.stats.get_current_max_throw_charge_time()
	var curr_charge = character.throw_item_stopwatch.time_elapsed_sec
	progress_bar.value = 100.0 * min(curr_charge, max_charge) / max_charge

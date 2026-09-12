extends Node

var pa_units : Array[PaUnit] = []


func register_pa_unit(pa_unit : PaUnit) -> void:
	if not pa_units.has(pa_unit):
		pa_units.append(pa_unit)


func unregister_pa_unit(pa_unit : PaUnit) -> void:
	pa_units.erase(pa_unit)


## True if a unit with its button pressed picks this position up. Only pressed units are
## microphones; every unit plays what other units pick up regardless of its own button.
func is_broadcast_source(world_position : Vector3) -> bool:
	for unit in pa_units:
		if unit.is_broadcasting() and unit.covers_input(world_position):
			return true
	return false


## True if some unit would play a speaker at speaker_position out to listener_position.
## A unit never replays someone standing in its own radius - they are already heard directly.
func has_listener_unit(listener_position : Vector3, speaker_position : Vector3) -> bool:
	for unit in pa_units:
		if unit.covers_output(listener_position) and not unit.covers_output(speaker_position):
			return true
	return false


## Plays a speaker's voice out of every unit that another unit picked them up for.
func relay_voice(speaker_id : int, speaker_position : Vector3, frames : PackedVector2Array, mix_rate : float) -> void:
	if not is_broadcast_source(speaker_position):
		return
	for unit in pa_units:
		if not unit.covers_output(speaker_position):
			unit.push_voice(speaker_id, frames, mix_rate)

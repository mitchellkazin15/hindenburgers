extends Node

var pa_units : Array[PaUnit]
var all_streams_set = false


func register_pa_unit(pa_unit : PaUnit):
	pa_units.append(pa_unit)
	all_streams_set = false


func _physics_process(delta: float) -> void:
	if not all_streams_set:
		set_all_streams()


func set_all_streams():
	for output_pa_unit in pa_units:
		var i = 1
		for input_pa_unit in pa_units:
			if output_pa_unit == input_pa_unit:
				continue
			output_pa_unit.sync_stream.set_sync_stream(AudioStreamSynchronized.MAX_STREAMS - i, input_pa_unit.sync_stream)
			i += 1
	all_streams_set = true

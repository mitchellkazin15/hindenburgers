extends Node

var stopwatch_refs = []


func create_stopwatch(process_always = true, process_in_physics = false, ignore_timescale = false) -> Stopwatch:
	var stopwatch = Stopwatch.new(process_always, process_in_physics, ignore_timescale)
	stopwatch_refs.append(weakref(stopwatch))
	return stopwatch


func _process_stopwatches(delta: float, physics_frame: bool):
	var erase_list = []
	for ref : WeakRef in stopwatch_refs:
		var stopwatch : Stopwatch = ref.get_ref()
		if not stopwatch:
			erase_list.append(ref)
			continue
		if stopwatch._stopped or (get_tree().paused and not stopwatch._process_always) or (stopwatch._process_in_physics != physics_frame):
			continue
		if stopwatch._ignore_timescale:
			stopwatch.time_elapsed_sec += delta / Engine.time_scale
		else:
			stopwatch.time_elapsed_sec += delta
	for erase in erase_list:
		stopwatch_refs.erase(erase)


func _physics_process(delta: float) -> void:
	_process_stopwatches(delta, true)


func _process(delta: float) -> void:
	_process_stopwatches(delta, false)

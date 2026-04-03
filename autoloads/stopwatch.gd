class_name Stopwatch
extends RefCounted

var time_elapsed_sec: float

var _process_always: bool
var _process_in_physics: bool
var _ignore_timescale: bool
var _stopped = false


func _init(process_always: bool, process_in_physics: bool, ignore_timescale: bool) -> void:
	_process_always = process_always
	_process_in_physics = process_in_physics
	_ignore_timescale = ignore_timescale


func stop():
	_stopped = true


## Start stopwatch again after it was stopped. Do not need to call when created with StopwatchManager.create_stopwatch
func start():
	_stopped = false


func restart():
	time_elapsed_sec = 0.0

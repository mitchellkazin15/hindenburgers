extends Panel
class_name TimePanel

var time: float = 0.0
var hours: int = 0
var minutes: int = 0
var seconds: int = 0
var initial_scale


func _ready() -> void:
	initial_scale = scale
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	call_deferred("_on_viewport_size_changed")


func _on_viewport_size_changed():
	scale = initial_scale * (get_viewport().size.x / 1920.0)


func _process(delta):
	time += delta
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	hours = fmod(time, 86400) / 3600

	$Seconds.text = "%02d" % seconds
	$Minutes.text = "%02d:" % minutes
	$Hours.text = "%02d:" % hours

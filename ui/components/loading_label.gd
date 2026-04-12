class_name LoadingLabel
extends Label

## Number of changes to ellipses per second
@export var ellipses_frequency = 3.5

var ellapsed_time = 0.0
var base_text


func _ready() -> void:
	base_text = text


func _process(delta: float) -> void:
	ellapsed_time += delta
	if ellapsed_time >= 1.0 / ellipses_frequency:
		if text.length() == base_text.length() + 3:
			text = base_text
		else:
			text += "."
		ellapsed_time = 0.0

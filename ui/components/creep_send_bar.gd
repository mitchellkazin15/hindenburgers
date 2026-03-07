extends TextureProgressBar

@export
var glow_time: float = 0.7
var glowing: bool = false;
var start_glow: bool = false;
var glow_timer: Timer;

@onready
var label: Label = $Label


func _ready() -> void:
	label.text = ""


func _process(delta: float) -> void:
	if start_glow:
		glow_timer = Timer.new()
		glow_timer.wait_time = glow_time
		glow_timer.one_shot = true
		glow_timer.autostart = true
		glow_timer.connect("timeout", _on_glow_timer_timeout)
		add_child(glow_timer)
		start_glow = false
		glowing = true
	if glowing:
		var ellapsed_time_perc = glow_timer.time_left / glow_time
		if ellapsed_time_perc < 0.5:
			get_material().set_shader_parameter("glow_power", ellapsed_time_perc * 6.0)
		else:
			get_material().set_shader_parameter("glow_power", 6 - ellapsed_time_perc * 6.0)


func _on_glow_timer_timeout():
	glowing = false
	call_deferred("glow_timer.queue_free")
	get_material().set_shader_parameter("glow_power", 0.0)


func _on_creep_send_component_creep_send_update(current_value: float, next_send_value: float, current_combo: int) -> void:
	if next_send_value > max_value:
		start_glow = true
	max_value = next_send_value
	value = (float(current_value) / float(next_send_value)) * 100.0
	if current_combo > 0:
		label.text = str(current_combo) + "x"
	else:
		if label:
			label.text = ""

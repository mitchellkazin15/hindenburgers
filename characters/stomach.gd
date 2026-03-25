class_name Stomach
extends Node3D

@export var max_food_capacity = 100.0
@export var digestion_tick_val = 10.0
@export var digestion_period_sec = 30.0
@export var colon : Colon

var digestion_timer : SceneTreeTimer
var _curr_food_val = 0.0


func _ready() -> void:
	digestion_timer = get_tree().create_timer(digestion_period_sec)


func add_food(food_val):
	_curr_food_val = min(_curr_food_val + food_val, max_food_capacity)


func is_full() -> bool:
	return _curr_food_val == max_food_capacity


func _digest_food() -> float:
	_curr_food_val -= digestion_tick_val
	var num_digested = digestion_tick_val
	if _curr_food_val < 0.0:
		num_digested -= _curr_food_val
		_curr_food_val = 0.0
	return num_digested


func _physics_process(delta: float) -> void:
	if digestion_timer.time_left == 0.0:
		if not colon.is_full():
			var digested_val = _digest_food()
			colon.add_digested_food(digested_val)
		digestion_timer = get_tree().create_timer(digestion_period_sec)

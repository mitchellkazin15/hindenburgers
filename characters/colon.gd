class_name Colon
extends Node3D


@export var max_digested_food_capacity = 100.0

var _curr_digested_food_val = 0.0


func add_digested_food(digested_food_val):
	_curr_digested_food_val = min(_curr_digested_food_val + digested_food_val, max_digested_food_capacity)


func is_full() -> bool:
	return _curr_digested_food_val == max_digested_food_capacity

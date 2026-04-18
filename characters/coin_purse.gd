class_name CoinPurse
extends Node3D

@export var money_val = 0.0


func add_money(val : float):
	assert(val >= 0.0)
	update_money_val(val)


func spend_money(positive_price: float):
	assert(positive_price >= 0.0)
	update_money_val(-positive_price)


func update_money_val(change_val):
	money_val = max(0.0, money_val + change_val)

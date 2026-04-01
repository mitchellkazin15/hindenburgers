class_name CoinPurse
extends Node3D

var money_val = 0.0


func add_money(val : float):
	assert(val > 0.0)
	update_money_val.rpc(val)


func spend_money(positive_price: float):
	assert(positive_price > 0.0)
	update_money_val.rpc(-positive_price)


@rpc("any_peer", "call_local", "reliable")
func update_money_val(change_val):
	money_val = max(0.0, money_val + change_val)

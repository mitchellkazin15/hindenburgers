class_name MoneyEffect
extends ItemEffect

@export var money_value = 1.0


func can_apply(user : Node3D, use_charge_time : float) -> bool:
	return super.can_apply(user, use_charge_time) and user.has_node("CoinPurse")


func apply_effect(user : Node3D, _use_charge_time : float):
	var purse : CoinPurse = user.get_node("CoinPurse")
	purse.add_money(money_value)

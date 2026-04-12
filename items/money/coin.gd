class_name Coin
extends HoldableItem

@export var money_value = 1.0


func use(use_charge_time : float):
	if use_charge_time < max_use_charge_time:
		return
	if item_holder.has_node("CoinPurse"):
		var purse : CoinPurse = item_holder.get_node("CoinPurse")
		purse.add_money(money_value)
		MultiplayerManager.broadcast_queue_free(self)

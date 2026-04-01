class_name Coin
extends HoldableItem

@export var money_value = 1.0


func use():
	if item_holder.has_node("CoinPurse"):
		var purse : CoinPurse = item_holder.get_node("CoinPurse")
		purse.add_money(money_value)
		MultiplayerManager.broadcast_queue_free(self)

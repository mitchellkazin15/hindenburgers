class_name EdibleItem
extends HoldableItem

@export var food_val = 10.0


func use():
	if item_holder.has_node("Stomach"):
		var stomach : Stomach = item_holder.get_node("Stomach")
		if stomach.is_full():
			return
		stomach.add_food(food_val)
		MultiplayerManager.broadcast_queue_free(self)

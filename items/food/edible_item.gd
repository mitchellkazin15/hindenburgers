class_name EdibleItem
extends HoldableItem

@export var food_val = 10.0
@export var uses = 1.0;

var _amount_used = 0


func use():
	eat(item_holder)


func eat(eater : Node3D):
	if eater.has_node("Stomach"):
		var stomach : Stomach = eater.get_node("Stomach")
		if stomach.is_full():
			return
		stomach.add_food.rpc(food_val)
		_amount_used += 1
		if _amount_used == uses:
			MultiplayerManager.broadcast_queue_free(self)

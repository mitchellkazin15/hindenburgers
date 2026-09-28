class_name ConsumeEffect
extends ItemEffect

@export var uses = 1.0

var _amount_used = 0


func apply_effect(_user : Node3D, _use_charge_time : float):
	_amount_used += 1
	if _amount_used >= uses:
		MultiplayerManager.broadcast_queue_free(item)

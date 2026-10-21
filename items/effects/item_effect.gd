class_name ItemEffect
extends Node

@export var requires_full_charge = true

## Orientation of the item this effect came from, relative to [member item].
## Identity unless the effect was absorbed into a stack. Use it for any
## direction that should follow the original item rather than the stack.
var item_basis := Basis.IDENTITY
## Which stacked item this effect came from, -1 if not part of a stack.
## Effects from the same item apply all-or-nothing (see HoldableItem.apply_effects).
var source_index := -1

@onready var item : HoldableItem:
	get:
		return get_parent()


func can_apply(_user : Node3D, use_charge_time : float) -> bool:
	return not requires_full_charge or use_charge_time >= item.max_use_charge_time


func start_effect(_holder : Character):
	pass


func apply_effect(_user : Node3D, _use_charge_time : float):
	pass


func on_held(_holder : Character):
	pass


func on_released():
	pass


func get_charge_time(use_charge_time : float) -> float:
	return min(item.max_use_charge_time, use_charge_time)


func get_charge_ratio(use_charge_time : float) -> float:
	return min(use_charge_time / item.max_use_charge_time, 1.0)

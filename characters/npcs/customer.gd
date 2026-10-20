class_name Customer
extends RelativeRigidBody3D

@export var payment : PackedScene
@export var take_order_cooldown = 60.0
@export var order_valid_duration = 60.0
@export var possible_orders : Array[Recipe] = [preload("res://items/food/recipes/hamburger.tres") as Recipe]

var order_cooldown_timer : SceneTreeTimer
var order_valid_duration_timer : SceneTreeTimer
## Index into possible_orders, or -1 when there is no active order. This is what gets synced.
var current_order_index := -1
## The recipe this customer wants right now. Null when there is no active order.
var current_order : Recipe

var can_consume : bool:
	get:
		return current_order != null and order_valid_duration_timer.time_left > 0.0


func _ready() -> void:
	super._ready()
	add_to_group("customers")
	# Customers start frozen so they don't drift on load. Nothing unfreezes them yet.
	freeze = true
	order_cooldown_timer = get_tree().create_timer(0.0)
	order_valid_duration_timer = get_tree().create_timer(0.0)
	if payment:
		$Cloaca.poop_scene = payment


func can_take_order() -> bool:
	return (
		not possible_orders.is_empty() and
		order_cooldown_timer.time_left == 0.0 and
		order_valid_duration_timer.time_left == 0.0
	)


## Call on the peer that has authority over this customer. The random pick is
## made here and only the index is sent, so every peer ends up with the same order.
func request_order() -> void:
	if not can_take_order():
		return
	take_order.rpc(randi_range(0, possible_orders.size() - 1))


@rpc("any_peer", "call_local", "reliable")
func take_order(recipe_index : int) -> void:
	if not can_take_order() or recipe_index < 0 or recipe_index >= possible_orders.size():
		return
	_set_current_order(recipe_index)
	order_valid_duration_timer = get_tree().create_timer(order_valid_duration)


## Returns true if [param item] fulfilled the current order and was consumed.
## Returning false means the caller should spit the item back out.
func consume_item(item : HoldableItem) -> bool:
	if not can_consume or not current_order.matches(_get_ingredient_entries(item)):
		return false
	broadcast_consumed.rpc()
	item.apply_effects(self)
	return true


@rpc("any_peer", "call_local", "reliable")
func broadcast_consumed() -> void:
	_set_current_order(-1)
	order_valid_duration_timer = get_tree().create_timer(0.0)
	order_cooldown_timer = get_tree().create_timer(take_order_cooldown)


## Server only. Sends the active order and its remaining timers to a peer that has
## finished spawning, so it shows the same order as everyone else.
func sync_order_to_peer(peer_id : int) -> void:
	sync_order_state.rpc_id(
		peer_id,
		current_order_index,
		order_valid_duration_timer.time_left,
		order_cooldown_timer.time_left,
	)


@rpc("authority", "call_local", "reliable")
func sync_order_state(recipe_index : int, valid_time_left : float, cooldown_time_left : float) -> void:
	if valid_time_left <= 0.0:
		recipe_index = -1
	_set_current_order(recipe_index)
	order_valid_duration_timer = get_tree().create_timer(max(valid_time_left, 0.0))
	order_cooldown_timer = get_tree().create_timer(max(cooldown_time_left, 0.0))


func _set_current_order(recipe_index : int) -> void:
	current_order_index = recipe_index
	current_order = possible_orders[recipe_index] if recipe_index >= 0 else null


## One {"scene", "state"} Dictionary per item in the stack. A single item counts as a stack of one.
func _get_ingredient_entries(item : HoldableItem) -> Array:
	if item is BaseStackedItem:
		var stack := item as BaseStackedItem
		var entries := []
		for i in stack.stacked_scenes.size():
			entries.append({"scene": stack.stacked_scenes[i], "state": stack.stacked_states[i]})
		return entries
	return [{"scene": item.scene_file_path, "state": item.get_item_state()}]

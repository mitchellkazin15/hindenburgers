class_name TakeOrderItemArea3D
extends InteractableArea3D

@export var customer : Customer
@export var label : Label3D


func set_glow():
	if not multiplayer.has_multiplayer_peer():
		return
	var player : Character = EventService.find_player_by_peer(multiplayer.get_unique_id())
	if not player:
		return
	if customer.can_take_order():
		label.outline_modulate = Color(0.0, 0.5, 0.0, 1.0)
	else:
		label.outline_modulate = Color(0.5, 0.0, 0.0, 1.0)


func remove_glow():
	label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)


func interact(interacting_node: Node) -> void:
	if (not MultiplayerManager.safe_is_multiplayer_authority(self) or
		not interacting_node is Character or
		not customer.can_take_order()
	):
		return
	customer.request_order()


func _physics_process(delta: float) -> void:
	if customer.can_take_order():
		label.text = "Take Order"
	elif customer.order_cooldown_timer.time_left > 0.0:
		label.text = "Not Hungry: %.0f" % customer.order_cooldown_timer.time_left
	elif customer.can_consume:
		label.text = customer.current_order.display_name + (": %.0f" % customer.order_valid_duration_timer.time_left)

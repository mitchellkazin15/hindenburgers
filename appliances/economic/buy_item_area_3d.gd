class_name BuyItemArea3D
extends InteractableArea3D

@export var vending_machine : VendingMachine
@export var label : Label3D


func set_glow():
	label.outline_modulate = Color(0.0, 0.5, 0.0, 1.0)
	if not multiplayer.has_multiplayer_peer():
		return
	var player : Character = EventService.find_player_by_peer(multiplayer.get_unique_id())
	if not player:
		return
	var purse = get_purse(player)
	if not purse or not can_purchase(purse):
		label.outline_modulate = Color(0.5, 0.0, 0.0, 1.0)


func remove_glow():
	label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character:
		return
	var character : Character = interacting_node
	var purse = get_purse(character)
	if not purse or not can_purchase(purse):
		return
	purse.spend_money(vending_machine.price)
	vending_machine.dispense_item()


func get_purse(character : Character) -> CoinPurse:
	if not character.has_node("CoinPurse"):
		return null
	var purse : CoinPurse = character.get_node("CoinPurse")
	return purse


func can_purchase(purse : CoinPurse) -> bool:
	return purse.money_val >= vending_machine.price

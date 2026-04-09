class_name BuyItemArea3D
extends InteractableArea3D

@export var vending_machine : VendingMachine


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character:
		return
	var character : Character = interacting_node
	if not character.has_node("CoinPurse"):
		return
	var purse : CoinPurse = character.get_node("CoinPurse")
	if purse.money_val < vending_machine.price:
		return
	purse.spend_money(vending_machine.price)
	vending_machine.dispense_item()

class_name BankTransferArea3D
extends InteractableArea3D

enum TranferType {DEPOSIT, WITHDRAW}
@export var transfer_type : TranferType
@export var vault : CoinPurse
@export var label : Label3D


func set_glow():
	label.outline_modulate = Color(0.0, 0.5, 0.0, 1.0)


func remove_glow():
	label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)


func interact(interacting_node: Node) -> void:
	if not interacting_node is Character:
		return
	var character : Character = interacting_node
	if not character.has_node("CoinPurse"):
		return
	var purse : CoinPurse = character.get_node("CoinPurse")
	if transfer_type == TranferType.DEPOSIT:
		vault.add_money(purse.money_val)
		purse.spend_money(purse.money_val)
	elif transfer_type == TranferType.WITHDRAW:
		purse.add_money(vault.money_val)
		vault.spend_money(vault.money_val)

class_name Atm
extends StaticBody3D

@export var vault : CoinPurse
@export var label : Label3D


func _process(delta: float) -> void:
	label.text = "ATM\nBalance: $%.2f" % vault.money_val

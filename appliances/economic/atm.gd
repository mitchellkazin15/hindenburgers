class_name Atm
extends StaticBody3D

@export var label : Label3D


func _process(delta: float) -> void:
	label.text = "ATM\nBalance: $%.2f" % AtmCoinPurse.money_val

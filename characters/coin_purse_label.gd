class_name CoinPurseLabel
extends Control

@export var coin_purse : CoinPurse


func _process(delta: float) -> void:
	$Label.text = "=%.2f" % coin_purse.money_val

class_name CharacterSaveFile
extends Resource

@export var coin_purse_money_val : float


func serialize() -> Array:
	var vals = []
	vals.append(coin_purse_money_val)
	return vals


static func deserialize(val_list : Array) -> CharacterSaveFile:
	var save_file = CharacterSaveFile.new()
	save_file.coin_purse_money_val = val_list[0]
	return save_file

class_name CharacterSelector
extends Button

signal values_updated

@export var characters : Array[PackedScene]
@export var sprites : Array[CompressedTexture2D]
@export var display : TextureRect
@export var left_button : Button
@export var right_button : Button

var index
var selected


func _ready():
	index = 0
	selected = false
	left_button.focus_entered.connect(select_left)
	right_button.focus_entered.connect(select_right)
	handle_selection()


func select_right():
	index += 1
	if index >= characters.size():
		index = 0
	handle_selection()


func select_left():
	index -= 1
	if index < 0:
		index = characters.size() - 1
	handle_selection()


func handle_selection():
	var image = Image.load_from_file(sprites[index].resource_path)
	var texture = ImageTexture.create_from_image(image)
	display.texture = texture
	await get_tree().create_timer(0.1).timeout
	grab_focus()


func get_character_scene():
	return characters[index]

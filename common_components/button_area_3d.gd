class_name ButtonArea3D
extends InteractableArea3D

@export var is_pressed = false
@export var button_mesh : MeshInstance3D

var light : OmniLight3D
var button_starting_pos : Vector3


func _ready() -> void:
	button_starting_pos = button_mesh.position
	if has_node("OmniLight3D"):
		light = get_node("OmniLight3D")
		light.hide()


func set_glow():
	if light:
		light.show()


func remove_glow():
	if light:
		light.hide()


func interact(interacting_node: Node) -> void:
	is_pressed = not is_pressed


func _physics_process(delta: float) -> void:
	if is_pressed:
		button_mesh.scale.y = 0.5
		button_mesh.position.y = button_starting_pos.y - (0.5 * button_mesh.mesh.height)
	else:
		button_mesh.scale.y = 1.0
		button_mesh.position = button_starting_pos

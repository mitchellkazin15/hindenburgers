class_name InteractionRayCast3D
extends RayCast3D

@export var character : Character

var prev_interact_area : InteractableArea3D = null


func _physics_process(delta: float) -> void:
	if prev_interact_area:
		prev_interact_area.remove_glow()
	var interact_area = get_interactable_area_collider()
	if not interact_area or character.holding_item:
		return
	interact_area.set_glow()
	prev_interact_area = interact_area


func get_interactable_area_collider() -> InteractableArea3D:
	var collider = self.get_collider()
	if not collider is InteractableArea3D:
		return null
	var interactable_area : InteractableArea3D = collider
	return interactable_area

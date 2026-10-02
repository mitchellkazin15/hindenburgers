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


## Max colliders to skip past in one query, as a safety net against endless loops.
const MAX_SKIPPED_COLLIDERS = 8


## Returns the first InteractableArea3D along the ray that can currently be
## interacted with. Areas that can't (e.g. a GrabItemArea3D whose item is
## being held, which includes living characters) are skipped so they don't
## block items behind them. Any other collider (walls, etc.) still blocks.
func get_interactable_area_collider() -> InteractableArea3D:
	var result : InteractableArea3D = null
	var skipped_any = false
	for i in MAX_SKIPPED_COLLIDERS:
		var collider = self.get_collider()
		if not collider is InteractableArea3D:
			break
		if _can_interact_with(collider):
			result = collider
			break
		add_exception(collider)
		skipped_any = true
		force_raycast_update()
	if skipped_any:
		clear_exceptions()
	return result


func _can_interact_with(area : InteractableArea3D) -> bool:
	if area is GrabItemArea3D:
		return not area.item.being_held
	return true

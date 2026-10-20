class_name RecipeIngredient
extends Resource

## The item scene this ingredient needs.
@export var scene : PackedScene
## Every key must be present in the item's state with an equal value,
## e.g. {"cook_state": "cooked"}. Empty accepts any state.
@export var required_state : Dictionary = {}


## [param entry] is {"scene": scene_file_path, "state": state Dictionary} for one item in a stack.
func accepts(entry : Dictionary) -> bool:
	if not scene or entry.get("scene") != scene.resource_path:
		return false
	var state : Dictionary = entry.get("state", {})
	for key in required_state:
		if not state.has(key) or state[key] != required_state[key]:
			return false
	return true

class_name Recipe
extends Resource

@export var display_name : String = ""
## Each ingredient must be matched by exactly one item, and the stack may not hold
## anything that isn't matched. Order does not matter.
@export var ingredients : Array[RecipeIngredient] = []


## [param entries] holds one {"scene", "state"} Dictionary per item in the stack.
func matches(entries : Array) -> bool:
	if entries.size() != ingredients.size():
		return false
	var used := []
	used.resize(entries.size())
	used.fill(false)
	return _assign(0, entries, used)


## Tries to give each ingredient from [param ingredient_index] on a distinct entry.
## Backtracks so that an ingredient that accepts several entries doesn't steal one
## another ingredient needs.
func _assign(ingredient_index : int, entries : Array, used : Array) -> bool:
	if ingredient_index == ingredients.size():
		return true
	var ingredient := ingredients[ingredient_index]
	if not ingredient:
		push_warning("Recipe '%s' has an empty ingredient slot" % display_name)
		return false
	for i in entries.size():
		if used[i] or not ingredient.accepts(entries[i]):
			continue
		used[i] = true
		if _assign(ingredient_index + 1, entries, used):
			return true
		used[i] = false
	return false

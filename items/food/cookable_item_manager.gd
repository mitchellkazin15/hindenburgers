class_name CookableItemManager
extends Node3D

const COOK_STATE_RAW := "raw"
const COOK_STATE_HALF_COOKED := "half_cooked"
const COOK_STATE_COOKED := "cooked"
const COOK_STATE_BURNT := "burnt"

@onready var top_raycast = $TopRayCast3D
@onready var bottom_raycast = $BottomRayCast3D

@export var top_mesh : MeshInstance3D
@export var bottom_mesh : MeshInstance3D
@export var per_side_cook_time = 30.0
@export var per_side_burn_time = 60.0
@export var cooked_color : Color
@export var burnt_color : Color

var top_side_cook_timer : Stopwatch
var bottom_side_cook_timer : Stopwatch
var burnt = false


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	top_side_cook_timer = StopwatchManager.create_stopwatch()
	bottom_side_cook_timer = StopwatchManager.create_stopwatch()


## Merged into the holdable's state, so a stack records how the item was cooked
## at the moment it was added.
func get_item_state() -> Dictionary:
	return {
		"cook_state": get_cook_state(),
		"top_cooked": _is_side_cooked(top_side_cook_timer),
		"bottom_cooked": _is_side_cooked(bottom_side_cook_timer),
	}


## Restores the look of a recorded state on a freshly instanced patty, before its
## meshes are moved into a stack. Without this the stacked patty would show raw.
func apply_item_state(state : Dictionary) -> void:
	if state.get("cook_state") == COOK_STATE_BURNT:
		_paint(true, burnt_color)
		_paint(false, burnt_color)
		return
	if state.get("top_cooked", false):
		_paint(true, cooked_color)
	if state.get("bottom_cooked", false):
		_paint(false, cooked_color)


## Each patty instance gets its own material. The mesh and material are shared by
## every instance of the scene, so painting them directly recolours every patty.
func _paint(top : bool, color : Color) -> void:
	var mesh_instance : MeshInstance3D = top_mesh if top else bottom_mesh
	if not mesh_instance:
		mesh_instance = get_parent().get_node_or_null("TopMesh" if top else "BottomMesh")
	if not mesh_instance:
		return
	var material := mesh_instance.material_override as StandardMaterial3D
	if not material:
		material = (mesh_instance.mesh.material as StandardMaterial3D).duplicate()
		mesh_instance.material_override = material
	material.albedo_color = color


func get_cook_state() -> String:
	if _is_side_burnt(top_side_cook_timer) or _is_side_burnt(bottom_side_cook_timer):
		return COOK_STATE_BURNT
	var top_cooked = _is_side_cooked(top_side_cook_timer)
	var bottom_cooked = _is_side_cooked(bottom_side_cook_timer)
	if top_cooked and bottom_cooked:
		return COOK_STATE_COOKED
	if top_cooked or bottom_cooked:
		return COOK_STATE_HALF_COOKED
	return COOK_STATE_RAW


func _is_side_cooked(timer : Stopwatch) -> bool:
	return timer.time_elapsed_sec > per_side_cook_time


func _is_side_burnt(timer : Stopwatch) -> bool:
	return timer.time_elapsed_sec > per_side_burn_time


func _physics_process(delta: float) -> void:
	if not MultiplayerManager.safe_is_server():
		return
	if burnt:
		return
	var top_cooked = _is_side_cooked(top_side_cook_timer)
	var bottom_cooked = _is_side_cooked(bottom_side_cook_timer)
	if top_cooked or bottom_cooked:
		display_cooked_sides.rpc(top_cooked, bottom_cooked)
	if top_raycast.get_collider() is CookingBody:
		top_side_cook_timer.start()
	else:
		top_side_cook_timer.stop()
	if bottom_raycast.get_collider() is CookingBody:
		bottom_side_cook_timer.start()
	else:
		bottom_side_cook_timer.stop()
	burnt = _is_side_burnt(top_side_cook_timer) or _is_side_burnt(bottom_side_cook_timer)
	if burnt:
		top_side_cook_timer.stop()
		bottom_side_cook_timer.stop()
		display_burnt.rpc()


@rpc("any_peer", "call_local", "reliable")
func display_cooked_sides(top_cooked, bottom_cooked):
	if top_cooked:
		_paint(true, cooked_color)
	if bottom_cooked:
		_paint(false, cooked_color)


@rpc("any_peer", "call_local", "reliable")
func display_burnt():
	_paint(true, burnt_color)
	_paint(false, burnt_color)

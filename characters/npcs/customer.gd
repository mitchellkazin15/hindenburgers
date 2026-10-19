class_name Customer
extends RelativeRigidBody3D

@export var eat_list_override : Array[String]
@export var payment : PackedScene
@export var take_order_cooldown = 60.0
@export var order_valid_duration = 60.0

var _can_take_order = true
var can_consume : bool:
	get:
		return order_valid_duration_timer.time_left > 0.0
var order_cooldown_timer : SceneTreeTimer
var order_valid_duration_timer : SceneTreeTimer
var current_order : String

func _ready() -> void:
	super._ready()
	order_cooldown_timer = get_tree().create_timer(0.0)
	order_valid_duration_timer = get_tree().create_timer(0.0)
	if eat_list_override and eat_list_override.size() > 0:
		$SuckArea3D.eat_list = eat_list_override
	if payment:
		$Cloaca.poop_scene = payment


func can_take_order():
	return (
		_can_take_order and 
		order_cooldown_timer.time_left == 0.0 and 
		order_valid_duration_timer.time_left == 0.0
	)


func consume_item(item : HoldableItem) -> bool:
	if not item is BaseStackedItem or not can_consume:
		return false
	var stack = item as BaseStackedItem
	broadcast_consumed.rpc()
	item.apply_effects(self)
	return true


@rpc("any_peer", "call_local", "reliable")
func broadcast_consumed():
	order_valid_duration_timer = get_tree().create_timer(0.0)
	_can_take_order = false
	order_cooldown_timer = get_tree().create_timer(take_order_cooldown)


@rpc("any_peer", "call_local", "reliable")
func take_order():
	if can_take_order:
		order_valid_duration_timer = get_tree().create_timer(order_valid_duration)
		order_valid_duration_timer.timeout.connect(_on_order_valid_timeout)
		_can_take_order = false
		current_order = "Hamburger"
	else:
		current_order = "Error"


func _on_order_valid_timeout():
	_can_take_order = true


func _on_order_cooldown_timeout():
	_can_take_order = true

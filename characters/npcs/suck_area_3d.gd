class_name SuckArea3D
extends Area3D

@export var customer : Customer
@export var mouth : Node3D
@export var suck_time = 2.0

var suck_item : RigidBody3D = null
var suck_reset_timer : SceneTreeTimer
var suck_reset_time = 0.5


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	body_entered.connect(_on_body_entered)
	suck_reset_timer = get_tree().create_timer(0.0)


func _on_body_entered(body):
	if suck_item or not is_multiplayer_authority() or suck_reset_timer.time_left != 0.0:
		return
	if body is RigidBody3D and body != get_parent():
		if not body is HoldableItem or body.being_held:
			return
		body.freeze
		suck_item = body
		var tween = get_tree().create_tween()
		tween.tween_property(body, "global_position", mouth.global_position, suck_time)
		tween.finished.connect(_on_suck_finished)


func _on_suck_finished():
	if not suck_item:
		return
	suck_item.freeze = false
	suck_reset_timer = get_tree().create_timer(suck_reset_time)
	if suck_item is EdibleItem:
		suck_item.eat(customer)
	else:
		suck_item.apply_central_impulse(20.0 * mouth.global_basis.z + 5.0 * Vector3.UP)
	suck_item = null

class_name AirMine
extends RelativeRigidBody3D

@export var explosion_power = 100000000.0
@export var reset_time = 10.0

var reset_timer : SceneTreeTimer


func _ready() -> void:
	super._ready()
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	$ContactArea.body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if reset_timer and reset_timer.time_left != 0.0:
		return
	if body is RelativeRigidBody3D and body != self:
		$ExplosionArea3D.explode(explosion_power)
		reset_timer = get_tree().create_timer(reset_time)
		show_explosing.rpc()


@rpc("any_peer", "call_local", "reliable")
func show_explosing():
	$GPUParticles3D.restart()

class_name KnifeInteractionArea3D
extends Area3D

@export var spawn_at_collision_scene : PackedScene
@export var spawn_cooldown_time = 0.1


var spawn_cooldown_timer : SceneTreeTimer


func _ready() -> void:
	spawn_cooldown_timer = get_tree().create_timer(0.0)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority() or spawn_cooldown_timer.time_left != 0.0:
		return
	for collider in get_overlapping_areas():
		if collider is KnifeDamageArea3D and collider.get_parent().active:
			var spawn = spawn_at_collision_scene.instantiate()
			MultiplayerManager.add_node_to_spawner(spawn, collider.global_position)
			if spawn is RelativeRigidBody3D:
				spawn.apply_relative_central_impulse(5.0 * (collider.global_position - self.global_position)  * spawn.mass)
			spawn_cooldown_timer = get_tree().create_timer(spawn_cooldown_time)
			return

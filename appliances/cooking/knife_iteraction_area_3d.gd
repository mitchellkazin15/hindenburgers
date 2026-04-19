class_name KnifeInteractionArea3D
extends Area3D

@export var spawn_at_collision_scene : PackedScene
@export var spawn_cooldown_time = 0.1


var spawn_cooldown_timer : SceneTreeTimer


func _ready() -> void:
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	spawn_cooldown_timer = get_tree().create_timer(0.0)


func _physics_process(delta: float) -> void:
	if not MultiplayerManager.safe_is_multiplayer_authority(self) or spawn_cooldown_timer.time_left != 0.0:
		return
	for collider in get_overlapping_areas():
		if collider is KnifeDamageArea3D and collider.get_parent().active:
			var spawn = MultiplayerManager.add_node_to_spawner(spawn_at_collision_scene.resource_path, collider.global_position)
			if spawn is RelativeRigidBody3D:
				spawn.apply_relative_central_impulse(5.0 * (collider.global_position - self.global_position)  * spawn.mass)
			spawn_cooldown_timer = get_tree().create_timer(spawn_cooldown_time)
			return

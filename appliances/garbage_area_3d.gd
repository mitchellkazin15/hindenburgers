class_name GarbageArea3D
extends Area3D


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	for body in get_overlapping_bodies():
		if body is StaticBody3D or body is Character:
			continue
		if body is HoldableItem and body.being_held:
			continue
		if body is Vehicle and body.being_driven:
			continue
		MultiplayerManager.broadcast_queue_free(body)

class_name HealthComponent
extends Node

signal health_update(current_health, base_health, difference)
signal invulnerable(invurnerable, duration_sec)
signal died

@export var stats : StatManager
@export var current_health : float

var _prev_full_health : float
var _invulnerable = false
var _invulnability_timer : SceneTreeTimer
var _unkillable = false


func _ready():
	if not stats.is_node_ready():
		await stats.ready
	current_health = _get_current_full_health()
	_prev_full_health = current_health
	# Current health is full health at this point
	health_update.emit(current_health, _get_current_full_health(), 0.0)
	stats.stat_updated.connect(_on_stat_updated)


func is_full_health():
	return current_health == _get_current_full_health()


func apply_damage(damage, damaging_entity = null):
	if current_health <= 0 or _invulnerable:
		return
	var damage_applied = min(current_health, damage)
	current_health -= damage_applied
	if current_health <= 0 :
		current_health = 0
		if not _unkillable :
			died.emit()
	health_update.emit(current_health, _get_current_full_health(), -damage_applied)


func apply_healing(health, healing_entity = null):
	var healing_applied = min(_get_current_full_health() - current_health, health)
	current_health += healing_applied
	if current_health >= _get_current_full_health():
		current_health = _get_current_full_health()
	health_update.emit(current_health, _get_current_full_health(), healing_applied)


func apply_percentage_healing(percentage, healing_entity = null):
	apply_healing(_get_current_full_health() * (percentage / 100.0), healing_entity)


func apply_percentage_damage(percentage, damaging_entity = null):
	apply_damage(_get_current_full_health() * (percentage / 100.0), damaging_entity)


func _get_current_health():
	return current_health


func _get_current_full_health():
	return stats.get_current_max_health()


func set_invulnerable(duration_sec):
	if _invulnerable:
		if _invulnability_timer.time_left < duration_sec:
			_invulnability_timer.time_left = duration_sec
		return
	_invulnerable = true
	_invulnability_timer = get_tree().create_timer(duration_sec, false, false)
	_invulnability_timer.timeout.connect(_on_invulnerability_timeout)
	invulnerable.emit(_invulnerable, duration_sec)


func set_unkillable(is_unkillable):
	_unkillable = is_unkillable


func _on_invulnerability_timeout():
	_invulnerable = false
	invulnerable.emit(_invulnerable, 0.0)


func _on_stat_updated(stat_name):
	if stat_name != "health":
		return
	var health_diff = _get_current_full_health() - _prev_full_health
	_prev_full_health = _get_current_full_health()
	if health_diff >= 0:
		apply_healing(health_diff)
		# Return because aplying healing will emit health_update
		return
	elif current_health > _get_current_full_health():
		current_health = _get_current_full_health()
	health_update.emit(current_health, _get_current_full_health(), health_diff)

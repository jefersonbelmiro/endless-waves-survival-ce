extends KinematicBody2D
class_name KinematicSummonBase

enum STATES { SPAWNING, IDLE, DEAD, HITTED }
const stats_keys = ["max_health", "attack_range"]

export var id = 'summon'
export var base_color = Color()

var state = STATES.IDLE
var data
var invoker
var summoner
var caster = self

onready var stats: Stats = $stats
onready var sprite = $sprite
onready var shadow = $shadow
onready var health_bar = $health_bar
onready var health_bar_hide_timer = $health_bar/health_bar_hide_timer
onready var hurt_box = $hurt_box
onready var hurt_box_collision = $hurt_box/collision_shape_2d
onready var collision = $collision_shape_2d

func _ready():
	for index in stats_keys.size():
		var key = stats_keys[index]
		if !key in data:
			continue

		if stats.modifier_keys.has(key):
			stats.set_raw_value(key, data[key])
		else:
			stats[key] = data[key]
	stats.current_health = stats.max_health
	stats.apply_modifiers()


func can_cast():
	return is_alive() && !is_disabled()


func is_alive():
	return !(state == STATES.DEAD || state == STATES.SPAWNING)


func is_disabled():
	return stats.is_disabled()


func get_data():
	return data


func get_cooldown():
	if 'cooldown' in data:
		return data.cooldown - (data.cooldown * stats.cooldown_reduction) 
	return 0


func get_attack_speed_time():
	return stats.attack_speed_time 


func get_max_projectiles():
	return data.get_max_projectiles()


func get_projectile_speed():
	return data.get_projectile_speed()


func get_duration():
	return data.get_duration()


func get_area():
	return data.get_area()


func add_modifiers_to_node(data_source, node: Node):
	if !'modifiers' in data_source || !data_source.modifiers:
		return
	node.modifiers = Global.sanitize_modifiers(data_source.modifiers) 


# @FIXME use area2d(circle) to detect targets
func get_closest_target(position_find = global_position, ignore = [], distance = stats.attack_range):
	return Targets.get_closest_target(position_find, ignore, distance)


func get_random_target():
	return Targets.get_random_target(global_position, [], stats.attack_range)


func die():
	if state == STATES.DEAD:
		return
	state = STATES.DEAD
	Global.add_dead_effect(global_position, base_color)
	queue_free()

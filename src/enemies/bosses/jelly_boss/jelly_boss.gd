extends TargetBase

var melee_scene = preload("res://src/enemies/bosses/jelly_boss/spawn/jelly_boss_melee/jelly_boss_melee.tscn")
var range_scene = preload("res://src/enemies/bosses/jelly_boss/spawn/jelly_boss_range/jelly_boss_range.tscn")

var phases_by_level = {
	2: [
		{ health = 1, handler = "_on_phase_0" },
	],
	3: [
		{ health = 1, handler = "_on_phase_0" },
		{ health = 0.8, handler = "_on_phase_1" },
		{ health = 0.4, handler = "_on_phase_2" },
		{ health = 0.1, handler = "_on_phase_3" },
	]
}


var phases = []
var phase_index = 0
var spawns = 0

func _ready():
	if phases_by_level.has(level):
		phases = phases_by_level[level]
	elif level > 3:
		phases = phases_by_level[3]

	if phases.size():
		stats.connect("health_changed", self, "_on_health_changed")
		_next_phase()


func die():
	if phase_index < phases.size() - 1:
		phase_index = phases.size() - 1
		_next_phase()
	.die()


func _on_spawn_deaded():
	spawns -= 1
	if spawns <= 0:
		Global.emit_signal("enemy_died", self)
		queue_free()

	
func _on_health_changed():
	if phase_index > phases.size() - 1:
		return
	var current = phases[phase_index]
	var health_percentage = stats.current_health/stats.max_health  
	if health_percentage <= current.health:
		_next_phase()


func _next_phase():
	if phase_index > phases.size() - 1:
		return
	var current = phases[phase_index]
	call(current.handler)
	phase_index += 1


func _on_phase_0():
	var data = {
		"auto_attack": true,
		"force": 12.0,
		"max_projectiles": 1,
		"attack_range": 500,
		"damage_knockback": 100,
		"color": "#1ebc73",
	}
	behaviour_container.add("launch_attack", data)
	

func _on_phase_1():
	var data = { cooldown = 2.0, target_id = 'jelly' }
	behaviour_container.add("call_shield_formation", data)


func _on_phase_2():
	var behaviour = AbsorbAndThrowBehaviour.new()
	var data = { cooldown = 2.0, target_id = 'jelly' }
	behaviour_container.set("absorb_and_throw", behaviour, data)


func _on_phase_3():
	state = STATES.DEAD
	hurt_box_collision.set_deferred('disabled', true)
	behaviour_container.remove("call_shield_formation")
	behaviour_container.remove("absorb_and_throw")
	behaviour_container.disable_group("move")
	behaviour_container.disable_group("attack")
	Global.add_enemy_dead_effect(global_position, base_color)
	hide()

	var node_melee = melee_scene.instance()
	node_melee.global_position = global_position + Vector2(-15, 0)
	node_melee.get_node("stats").connect("deaded", self, "_on_spawn_deaded")
	Global.add_entity_deferred(node_melee)

	var node_range = range_scene.instance()
	node_range.global_position = global_position + Vector2(15, 0)
	node_range.get_node("stats").connect("deaded", self, "_on_spawn_deaded")
	Global.add_entity_deferred(node_range)
	spawns = 2

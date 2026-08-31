extends TargetBase

const teleport_behaviour_script = preload("res://src/enemies/bosses/reaper_boss/behaviours/teleport.gd")
const range_attack_behaviour_script = preload("res://src/enemies/bosses/reaper_boss/behaviours/range_attack.gd")
const life_suck_behaviour_script = preload("res://src/enemies/bosses/reaper_boss/behaviours/life_suck.gd")
const dash_behaviour_script = preload("res://src/enemies/bosses/reaper_boss/behaviours/dash.gd")

var phases = [
	{ health = 1, handler = "_on_phase_0" },
	{ health = 0.8, handler = "_on_phase_1" },
	{ health = 0.5, handler = "_on_phase_2" },
	{ health = 0.2, handler = "_on_phase_3" },
]
var buffs_modifer
var rush_attack_collision_mask = 0
var teleport_check_map_bounds = false


func _ready():
	if 'rush_attack_collision_mask' in data:
		rush_attack_collision_mask = data.rush_attack_collision_mask
	if 'teleport_check_map_bounds' in data:
		teleport_check_map_bounds = data.teleport_check_map_bounds
	Global.create_phase_controller(self, phases, { phase_timeout = "03:00" })


func die():
	Global.session.score_bonus += 1000
	.die()


func die_effect():
	Global.add_enemy_dead_effect(global_position, base_color, 200, 4.0)


func _sync_stats_update():
	._sync_stats_update()
	var cast_anim_speed = sprite.frames.get_frame_count('cast') / stats.attack_speed_time 
	sprite.frames.set_animation_speed("cast", cast_anim_speed)


func _on_phase_0():
	behaviour_container.add("dash")
	behaviour_container.set("reaper_dash", dash_behaviour_script.new(), {
		proc_chance = 0.6,
		health_lost = 500,
	})
	behaviour_container.add("teleport")
	behaviour_container.set("reaper_teleport", teleport_behaviour_script.new(), {
		proc_chance = 0.5,
		cooldown = 3.0,
		health_lost = 1200,
		min_distance = 400,
		check_map_bounds = teleport_check_map_bounds,
	})
	behaviour_container.set("reaper_life_suck", life_suck_behaviour_script.new(), {
		proc_chance = 0.3,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 200.0,
		suck_duration = 1.0,
	})
	behaviour_container.set("reaper_range_attack", range_attack_behaviour_script.new(), {
		proc_chance = 0.7,
		cooldown = 3.0,
		cooldown_range = 1.0,
		attack_range = 300.0,
		projectile_speed = 100,
		projectiles = 8,
		attacks = 1,
	})
	behaviour_container.add("rush_attack", {
		proc_chance = 0.5,
		cooldown_range = 2.0,
		cooldown = 5.0,
		attack_range = 250,
		move_speed = 140,
		duration = 0.8,
		collision_mask = rush_attack_collision_mask,
	})


func _on_phase_1():
	behaviour_container.set_data("reaper_dash", {
		proc_chance = 0.8,
		health_lost = 500,
	})
	behaviour_container.set_data("reaper_teleport", {
		proc_chance = 0.8,
		cooldown = 3.0,
		health_lost = 1000,
		min_distance = 300,
	})
	behaviour_container.set_data("reaper_life_suck", {
		proc_chance = 0.6,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 400.0,
		suck_duration = 1.0,
	})
	behaviour_container.set_data("reaper_range_attack", {
		proc_chance = 0.7,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 300.0,
		projectile_speed = 100,
		projectiles = 8,
		attacks = 2,
	})
	behaviour_container.set_data("rush_attack", {
		proc_chance = 0.7,
		cooldown_range = 1.0,
		cooldown = 4.0,
		attack_range = 300,
		move_speed = 140,
		duration = 0.8,
	})


func _on_phase_2():
	behaviour_container.set_data("reaper_dash", {
		proc_chance = 0.9,
		health_lost = 500,
	})
	behaviour_container.set_data("reaper_teleport", {
		proc_chance = 0.9,
		cooldown = 3.0,
		health_lost = 800,
		min_distance = 250,
	})
	behaviour_container.set_data("reaper_life_suck", {
		proc_chance = 0.7,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 400.0,
		suck_duration = 1.0,
	})
	behaviour_container.set_data("reaper_range_attack", {
		proc_chance = 0.8,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 400.0,
		projectile_speed = 120,
		projectiles = 8,
		attacks = 3,
	})
	behaviour_container.set_data("rush_attack", {
		proc_chance = 0.8,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 400,
		move_speed = 150,
		duration = 0.8,
	})


func _on_phase_3():
	behaviour_container.set_data("reaper_dash", {
		proc_chance = 0.9,
		health_lost = 400,
	})
	behaviour_container.set_data("reaper_teleport", {
		proc_chance = 0.9,
		cooldown = 3.0,
		health_lost = 500,
		min_distance = 200,
	})
	behaviour_container.set_data("reaper_life_suck", {
		proc_chance = 0.8,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 500.0,
		suck_duration = 1.0,
	})
	behaviour_container.set_data("reaper_range_attack", {
		proc_chance = 0.9,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 400.0,
		projectile_speed = 140,
		projectiles = 8,
		attacks = 6,
	})
	behaviour_container.set_data("rush_attack", {
		proc_chance = 0.8,
		cooldown = 5.0,
		cooldown_range = 2.0,
		attack_range = 400,
		move_speed = 150,
		duration = 0.8,
	})
	stats.add_modifier({ 
		id = 'reaper_buffs',
		move_speed = 70,
		health_regen = int(level * 10),
		base_damage = 5 + int(level * 5),
		attack_speed = 40 + int(level * 10),
	})

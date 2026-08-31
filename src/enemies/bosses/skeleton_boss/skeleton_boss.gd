extends TargetBase

onready var axe_pivot = $axe_pivot
onready var axe_hit_box = $axe_pivot/hit_box_area
onready var axe_hit_box_collision = $axe_pivot/hit_box_area/collision_shape_2d

var phases = [
	{ health = 1, handler = "_on_phase_0" },
	{ health = 0.8, handler = "_on_phase_1" },
	{ health = 0.5, handler = "_on_phase_2" },
	# { health = 0.25, handler = "_on_phase_3" },
]
var phase_index = 0


func _ready():
	stats.connect("health_changed", self, "_on_health_changed")
	_next_phase()


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
		attack_range = 300,
		move_speed = 150,
		proc_chance = 0.9,
		cooldown = 3.0,
		cooldown_range = 1.0,
		duration = 1.0,
		collision_layer = "boss",
		collision_mask = ["env", "map_bounds"]
	}
	behaviour_container.add("rush_attack", data)
	

func _on_phase_1():
	var smash_attack_data = {
		proc_chance = 0.9,
		cooldown = 2.0,
		cooldown_range = 1.5,
		damage_knockback = 100,
	}
	var rush_attack_data = {
		proc_chance = 0.3,
		cooldown = 2.0,
		cooldown_range = 1.5,
		duration = 1.0,
	}
	behaviour_container.add("smash_attack", smash_attack_data)
	behaviour_container.set_data("rush_attack", rush_attack_data)


func _on_phase_2():
	var axe_attack_data = {
		damage_knockback = 150,
		proc_chance = 0.7,
		cooldown = 2.0,
		duration = 3.0,
		collision_layer = "boss",
		collision_mask = ["env", "map_bounds"]
	}
	var smash_attack_data = {
		proc_chance = 0.8,
		cooldown = 2.0,
		cooldown_range = 1.5,
	}
	behaviour_container.set("axe_attack", AxeAttackBehaviour.new(), axe_attack_data)
	behaviour_container.set_data("smash_attack", smash_attack_data)


func _on_phase_3():
	var axe_attack_data = {
		proc_chance = 0.8,
	}
	var smash_attack_data = {
		proc_chance = 0.6,
		cooldown = 1.5,
		cooldown_range = 1.0,
	}
	var rush_attack_data = {
		proc_chance = 0.4,
		cooldown = 2.0,
		cooldown_range = 1.0,
		duration = 1.0,
	}
	behaviour_container.set_data("axe_attack", axe_attack_data)
	behaviour_container.set_data("smash_attack", smash_attack_data)
	behaviour_container.set_data("rush_attack", rush_attack_data)

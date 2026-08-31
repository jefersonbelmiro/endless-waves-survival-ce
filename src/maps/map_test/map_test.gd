extends MapBase

const DEFAULT_DROPS_DATA = {
	#coin = { proc_chance = 1 },
	#experience = { proc_chance = 1, value = 10 },
	consumable_tier_1 = { proc_chance = 1 },
	consumable_tier_2 = { proc_chance = 1 },
	consumable_tier_3 = { proc_chance = 1 },
}

func _ready():
	event_system.events = []
	event_system.enemy_inc_level_at_kills = 1
	#event_system.stop()
	#objective_system.stop()
	#drop_system.stop()

	clear_spawn_data()
	set_all_spawn_data({ jelly = { drops = DEFAULT_DROPS_DATA.duplicate(true) } })

	# Global.event_add_mob_square(event_system, {
	# 	interval = 8, proc_chance = 0.9, spawn_id = 'ghost'
	# })

	# var targets = $targets
	# for index in targets.get_child_count():
	# 	var position = targets.get_child(index).global_position
	# 	var node = Global.spawn_id_scene.bat.instance()
	# 	node.global_position = position
	# 	node.data = get_spawn_data('bat', {
	# 		stats = {
	# 			move_speed = 0,
	# 		}
	# 	})
	# 	Global.add_entity(node)

	Global.event_add_reaper(event_system, {
		proc_chance = 1.0,
		interval = 1.0,
		start = 1.0,
	})

	event_system.add({
	  type = "spawn",
	  start = '20:00',
	  interval = 2,
	  data = {
		spawn_mode = "map_bounds",
		min_enemies_alive = 1,
		spawns = [
		   # { "id": "serpent_elite", min_enemies_alive = 1, max_enemies_alive = 1  },
		  #  { "id": "centipede_elite", size = 1, data = { stats = { max_health = 100000 } } },
		  # { "id": "jelly",
		  #max_enemies_alive = 0,
		  #min_enemies_alive = 0,
		  #data = { stats = { max_health = 100000, move_speed = 0 } } 
		  # },
		  #{ "id": "ghost", size = 1, },
		  #{ "id": "jelly_boss", size = 1, data = { level = 4 } },
		  # { "id": "jelly", size = 10, min_enemies_alive = 10 },
		  # # { "id": "skeleton", size = 2, data = { stats = { max_health = 10000 } } },
		   # { "id": "green_caterpillar", size = 1, data = { stats = { max_health = 100000 } } },
		   # { "id": "red_caterpillar", size = 1, data = { stats = { max_health = 100000 } } },
		  { "id": "jelly", min_enemies_alive = 5, max_enemies_alive = 5, data = { stats = { max_health = 100000, move_speed = 0, status_resistance = 1 } }  },
		  # { "id": "reaper_boss", min_enemies_alive = 1, max_enemies_alive = 1 },
		  # { "id": "skeleton_boss", size = 1, },
		  #  { "id": "jelly_boss", size = 1, data = { stats = { max_health = 100000 } }},
		# { "id": "skeleton_boss", size = 5, },
		 # { id = 'mob', type = 'mob', size = 1,  data = { spawn_size = 55, spawn_id = 'black_bat', spawn_type = 'circle', spawn_options = { radius = 15 } }},
		 # { id = 'mob', type = 'mob', size = 1,  data = { spawn_size = 5, spawn_id = 'bat', spawn_type = 'circle' }},
		 # { id = 'mob', type = 'mob', size = 1,  data = { spawn_size = 5, spawn_id = 'skeleton', spawn_type = 'column_left' }},
		]
	  }
	})


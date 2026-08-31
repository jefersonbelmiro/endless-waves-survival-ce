extends Reference

var map
var current_tier = 0
var last_tier_inc = 5
var last_tier_interval = "02:00"


func _init(map_):
	map = map_


func init():
	randomize()
	Global.connect("player_spawned", self, "_start")


func _start():
	map.event_system.max_enemies_alive = 150 if !Global.is_mobile() else 100
	map.event_system.enemy_inc_level_at_kills = 100
	map.event_system.spawn_mode = {
		mode = "outside_map_bounds",
		options = {
			min_range = map.spawn_min_range,
			max_range = map.spawn_max_range,
		}
	}

	_set_tier_1()
	_queue_tier(2, "00:30")
	_queue_tier(3, "04:00")
	_queue_tier(4, "06:00")
	_queue_tier(5, "08:00")
	_queue_tier(6, "10:00")
	_queue_tier(7, "13:00")

	var last_timer_start = Formatter.format_timer_seconds("15:00")
	Global.delay_func(self, "_set_last_tier_timer", last_timer_start, { pause_mode_process = false })


func _queue_tier(tier: int, start):
	var wait_time = Formatter.format_timer_seconds(start)  
	Global.delay_func(self, "_set_tier_%s" % [tier], wait_time, { pause_mode_process = false })


func _set_tier_1():
	current_tier += 1
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ jelly = { drops = _create_basic_drops() } })

	map.event_system.add({
		type = "spawn",
		data = { 
			spawn_mode =  "map_bounds",
			min_enemies_alive = 8,
			spawns = [{ id = "jelly", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 1, start = 5,
		data = { 
			min_enemies_alive = 10,
			max_enemies_alive = 30,
			respawn_factor = 2.0,
			spawns = [{ id = "jelly", }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 6,
		proc_chance = 0.2, interval = 30,
		spawn_options = { radius = 15, duration = 40 },
	}))

	map.event_system.start()


func _set_tier_2():
	current_tier += 1
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		jelly = { drops = _create_basic_drops(), level = current_tier },
		jelly_king = { drops = _create_elite_drops(), level = current_tier  },
		jelly_boss = {
			level = current_tier,
			drops = _create_boss_drops(),
		}, 
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 20,
			max_enemies_alive = 50,
			respawn_factor = 3.0,
			spawns = [{ id = "jelly", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			spawns = [{ id = "jelly_king", max_alive = 5 }]
		}
	})
	map.event_system.add({
		type = "spawn", start = "01:00",
		data = { 
			spawns = [{ id = "jelly_boss", max_alive = 1 }]
		}
	})
	map.event_system.add({
		type = "data_increment", start = "00:30", interval = "00:15",
		data = { id = "jelly", size = 1 }
	})

	map.event_system.start()


func _set_tier_3():
	current_tier += 1
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		skeleton = { drops = _create_basic_drops(), level = current_tier },
		skeleton_king = { drops = _create_elite_drops(), level = current_tier },
		ghost = { drops = _create_basic_drops(), level = current_tier },
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 20,
			max_enemies_alive = 40,
			respawn_factor = 4.0,
			spawns = [{ id = "skeleton", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			spawns = [{ id = "jelly_king", max_alive = 5 }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15, start = 15,
		proc_chance = 0.5,
		data = { 
			spawns = [{ id = "ghost", max_alive = 5 }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 10,
		proc_chance = 0.4, interval = 30, 
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.2, spawn_id = 'ghost', 
	})
	map.event_system.add({
		type = "data_increment", start = "00:30", interval = "00:20",
		data = { id = "skeleton", size = 2 }
	})

	map.event_system.start()


func _set_tier_4():
	current_tier += 1
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		bat = { drops = _create_basic_drops(), level = current_tier },
		eye = { drops = _create_basic_drops(), level = current_tier },
		ghost = { drops = _create_basic_drops(), level = current_tier },
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 20,
			max_enemies_alive = 40,
			respawn_factor = 5.0,
			spawns = [{ id = "bat", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			spawns = [{ id = "eye", max_alive = 5 }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15, start = 15,
		data = { 
			spawns = [{ id = "ghost", max_alive = 5}]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 12,
		proc_chance = 0.5, interval = 30, 
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.3, spawn_id = 'ghost', 
	})
	map.event_system.add({
		type = "data_increment", start = "00:30", interval = "00:20",
		data = { id = "bat", size = 2 }
	})

	map.event_system.start()


func _set_tier_5():
	current_tier += 1
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		green_caterpillar = { drops = _create_basic_drops(), level = current_tier },
		red_caterpillar = { drops = _create_basic_drops(), level = current_tier },
		skeleton_king_range = { drops = _create_elite_drops(), level = current_tier },
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 30,
			max_enemies_alive = 50,
			respawn_factor = 6.0,
			spawns = [{ id = "green_caterpillar", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 30,
			max_enemies_alive = 50,
			respawn_factor = 6.0,
			spawns = [{ id = "red_caterpillar", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			spawns = [{ id = "skeleton_king_range", max_alive = 5 }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 16,
		proc_chance = 0.6, interval = 30, 
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.4, spawn_id = 'ghost', 
	})
	map.event_system.add({
		type = "data_increment", start = "00:30", interval = "00:20",
		data = { id = "green_caterpillar", size = 2 }
	})
	map.event_system.add({
		type = "data_increment", start = "00:30", interval = "00:20",
		data = { id = "red_caterpillar", size = 2 }
	})

	map.event_system.start()


func _set_tier_6():
	current_tier += 1
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		skeleton = { drops = _create_basic_drops(), level = current_tier },
		skeleton_king = { drops = _create_elite_drops(), level = current_tier },
		skeleton_king_range = { drops = _create_elite_drops(), level = current_tier },
		skeleton_bomb = { drops = _create_basic_drops(), level = current_tier },
		skeleton_boss = {
			level = current_tier,
			drops = _create_boss_drops(),
		}, 
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 20,
			max_enemies_alive = 40,
			respawn_factor = 7.0,
			spawns = [{ id = "skeleton" }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			spawns = [{ id = "jelly_king", max_alive = 5 }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			spawns = [{ id = "skeleton_king_range", max_alive = 5 }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15, start = 15,
		data = { 
			spawns = [{ id = "skeleton_bomb", max_alive = 5 }]
		}
	})
	map.event_system.add({
		type = "spawn", start = "01:00",
		data = { 
			spawns = [{ id = "skeleton_boss", max_alive = 1 }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spanw_size = 18,
		proc_chance = 0.6, interval = 30, 
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.5, spawn_id = 'ghost', 
	})
	map.event_system.add({
		type = "data_increment", start = "00:30", interval = "00:20",
		data = { id = "skeleton", size = 3 }
	})

	map.event_system.start()


func _set_tier_7():
	current_tier += 1
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		ghost = { drops = _create_basic_drops(), level = current_tier },
		serpent_elite = {
			level = current_tier,
			drops = {
				coin = { proc_chance = 1.0, value = 150 },
				experience = { proc_chance = 1.0, value = 500 },
				consumable = { proc_chance = 1.0 },
				chest = { proc_chance = 1.0 }
			}
		}, 
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 20,
			max_enemies_alive = 30,
			respawn_factor = 8.0,
			spawns = [{ id = "ghost", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			spawns = [{ id = "book", max_alive = 5 }]
		}
	})
	map.event_system.add({
		type = "spawn", start = "01:00",
		data = { 
			spawns = [{ id = "serpent_elite", max_alive = 1 }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 20,
		proc_chance = 0.6, interval = 30, 
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.5, spawn_id = 'ghost', 
	})
	map.event_system.add({
		type = "data_increment", start = "00:30", interval = "00:15",
		data = { id = "ghost", size = 1  }
	})

	map.event_system.start() 


func _set_last_tier_timer():
	var node = Timer.new()
	node.autostart = true
	node.wait_time = Formatter.format_timer_seconds(last_tier_interval) 
	node.connect("timeout", self, "_set_last_tier")
	map.add_child(node)
	_set_last_tier()
	

func _set_last_tier():
	map.event_system.enemy_inc_level_at_kills = 1
	current_tier += last_tier_inc
	var handlers_size = 4
	var handler = "_set_last_tier_%s" % [randi() % handlers_size + 1]
	call(handler)


func _set_last_tier_1():
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		jelly = { level = _get_enemy_level(), drops = _create_basic_drops() },
		jelly_king = { level = _get_enemy_level(), drops = _create_elite_drops() },
		jelly_boss = {
			level = _get_enemy_level(),
			drops = {
				coin = { proc_chance = 1.0, value = 20 * current_tier },
				experience = { proc_chance = 1.0, value = 40 * current_tier },
				consumable = { proc_chance = 1.0 },
				chest = { proc_chance = 1.0, value = current_tier }
			}
		}, 
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 5 * current_tier,
			respawn_factor = 1 * current_tier,
			spawns = [{ id = "jelly", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			min_enemies_alive = current_tier,
			max_enemies_alive = 5 * current_tier,
			respawn_factor = 1 * current_tier,
			spawns = [{ id = "jelly_king", }]
		}
	})
	map.event_system.add({
		type = "spawn", start = "00:30",
		data = { 
			spawns = [{ id = "jelly_boss", max_alive = 1, }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 22,
		proc_chance = 0.7, interval = 30,
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.5, spawn_id = 'ghost',
	})
	Global.event_add_reaper(map.event_system)
	_set_data_increment('jelly')

	map.event_system.start() 


func _set_last_tier_2():
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		skeleton = { level = _get_enemy_level(), drops = _create_basic_drops() },
		skeleton_king = { level = _get_enemy_level(), drops = _create_elite_drops() },
		skeleton_king_range = { level = _get_enemy_level(), drops = _create_elite_drops() },
		skeleton_bomb = { level = _get_enemy_level(), drops = _create_basic_drops() },
		skeleton_boss = {
			level = _get_enemy_level(),
			drops = {
				coin = { proc_chance = 1.0, value = 20 * current_tier },
				experience = { proc_chance = 1.0, value = 40 * current_tier },
				consumable = { proc_chance = 1.0 },
				chest = { proc_chance = 1.0, value = current_tier }
			}
		}, 
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 5 * current_tier,
			respawn_factor = 1 * current_tier,
			spawns = [{ id = "skeleton", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			min_enemies_alive = current_tier,
			max_enemies_alive = 5 * current_tier,
			respawn_factor = 1 * current_tier,
			spawns = [{ id = "skeleton_king", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			max_enemies_alive = _get_enemy_level(),
			spawns = [{ id = "skeleton_king_range", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			max_enemies_alive = current_tier,
			spawns = [{ id = "skeleton_bomb", }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 22,
		proc_chance = 0.7, interval = 30,
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.5, spawn_id = 'ghost', 
	})
	map.event_system.add({
		type = "spawn", start = "00:30",
		data = { 
			spawns = [{ id = "skeleton_boss", max_alive = 1, }]
		}
	})
	Global.event_add_reaper(map.event_system)
	_set_data_increment('skeleton')

	map.event_system.start() 


func _set_last_tier_3():
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		green_caterpillar = { level = _get_enemy_level(), drops = _create_basic_drops() },
		red_caterpillar = { level = _get_enemy_level(), drops = _create_basic_drops() },
		ghost = { level = _get_enemy_level(), drops = _create_basic_drops() },
		eye = { level = _get_enemy_level(), drops = _create_basic_drops() },
		skeleton_bomb = { level = _get_enemy_level(), drops = _create_basic_drops() },
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 5 * current_tier,
			respawn_factor = 1 * current_tier,
			spawns = [{ id = "green_caterpillar", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			min_enemies_alive = current_tier,
			max_enemies_alive = 5 * current_tier,
			respawn_factor = 1 * current_tier,
			spawns = [{ id = "ghost", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			max_enemies_alive = 5 * current_tier,
			spawns = [{ id = "eye", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			max_enemies_alive = current_tier,
			spawns = [{ id = "skeleton_bomb", }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 22,
		proc_chance = 0.7, interval = 30,
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.5, spawn_id = 'ghost', 
	})
	Global.event_add_reaper(map.event_system)
	_set_data_increment('green_caterpillar')
	_set_data_increment('red_caterpillar')

	map.event_system.start() 


func _set_last_tier_4():
	map.event_system.clear({ keep_rates = true })
	map.clear_spawn_data()
	map.set_all_spawn_data({ 
		bat = { level = _get_enemy_level(), drops = _create_basic_drops() },
		eye = { level = _get_enemy_level(), drops = _create_basic_drops() },
		ghost = { level = _get_enemy_level(), drops = _create_basic_drops() },
		book = { level = _get_enemy_level(), drops = _create_elite_drops() },
		skeleton_bomb = { level = _get_enemy_level(), drops = _create_basic_drops() },
	})

	map.event_system.add({
		type = "spawn", interval = 3,
		data = { 
			min_enemies_alive = 5 * current_tier,
			respawn_factor = 1 * current_tier,
			spawns = [{ id = "bat", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			min_enemies_alive = current_tier,
			max_enemies_alive = 5 * current_tier,
			respawn_factor = 1 * current_tier,
			spawns = [{ id = "ghost", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			max_enemies_alive = 5 * current_tier,
			spawns = [{ id = "eye", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			max_enemies_alive = current_tier,
			spawns = [{ id = "skeleton_bomb", }]
		}
	})
	map.event_system.add({
		type = "spawn", interval = 15,
		data = { 
			max_enemies_alive = current_tier,
			spawns = [{ id = "book", }]
		}
	})
	map.event_system.add(Global.event_create_mob({
		spawn_id = 'black_bat', spawn_type = 'circle', spawn_size = 22,
		proc_chance = 0.7, interval = 30,
		spawn_options = { radius = 15, duration = 40 },
	}))
	Global.event_add_mob_square(map.event_system, {
		interval = 30, proc_chance = 0.5, spawn_id = 'ghost', 
	})
	Global.event_add_reaper(map.event_system)
	_set_data_increment('bat')

	map.event_system.start() 


func _get_enemy_level():
	if current_tier < 10:
	  return current_tier * 3
	if current_tier < 15:
	  return current_tier * 5
	if current_tier < 20:
	  return current_tier * 8
	return current_tier * 15


func _set_data_increment(id: String):
	map.event_system.add({
		type = "data_increment", start = "00:30", interval = "00:20", ticks = 20,
		data = { id = id, size = 1 }
	})


func _create_basic_drops():
	return {
		coin = { proc_chance = 0.1 },
		experience = { proc_chance = 0.7, value = 10 },
		consumable_tier_1 = { proc_chance = 0.01 }
	}


func _create_elite_drops():
	return {
		coin = { proc_chance = 0.5, value = 10  },
		experience = { proc_chance = 0.8, value = 5 * current_tier },
		consumable_tier_2 = { proc_chance = 0.05 },
	}


func _create_boss_drops():
	return {
		coin = { proc_chance = 0.9, value = 20 * current_tier },
		experience = { proc_chance = 0.9, value = 40 * current_tier },
		consumable_tier_3 = { proc_chance = 0.9 },
		chest = { proc_chance = 0.9, value = current_tier }
	}


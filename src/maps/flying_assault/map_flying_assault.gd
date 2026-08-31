extends MapBase

var spawn_data = {
	"bat": {
	  "stats": {
		"move_speed": 70,
	  },
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 10 },
		"consumable": { "proc_chance": 0.01 }
	  }
	},
	"bat_king": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 50 },
		"consumable": { "proc_chance": 0.01 }
	  }
	},
	"black_bat": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 10 },
		"consumable": { "proc_chance": 0.01 }
	  }
	},
	"ghost": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 50 },
		"consumable": { "proc_chance": 0.01 }
	  }
	},
	"eye": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 10 },
		"consumable": { "proc_chance": 0.01 }
	  }
	},
	"book": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 100 },
		"consumable": { "proc_chance": 0.2 }
	  }
	}
}


func _ready():
	var handler = "_set_level_%s" % [data.level]
	if !has_method(handler):
		return push_error("invalid handler: %s" % [handler])
		
	clear_spawn_data()
	set_all_spawn_data(spawn_data)
	call(handler)
	Global.event_add_reaper(event_system, { start = '15:00', })


func _set_level_1():
	# bat
	event_system.add({
	  "type": "spawn", "interval": 1,
	  "data": {
		"min_enemies_alive": 5,
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "bat", "size": 1, "max_alive": 10 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "01:00", "ticks": 8,
	  "data": { "id": "bat", "spawn_data": { "stats": { "base_damage": 1 } } }
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "01:30", "ticks": 5,
	  "data": { "id": "bat", "size": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "00:30", "interval": "00:30",
	  "data": { "id": "bat", "max_alive": 1 }
	})

	# bat king
	event_system.add({
	  "type": "spawn", "start": "02:00", "interval": 15,
	  "data": {
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "bat_king", "size": 1, "max_alive": 1 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "03:00", "interval": "03:00", "ticks": 3,
	  "data": { "id": "bat_king", "max_alive": 1 }
	})

	# mob black_bat
	event_system.add(Global.event_create_mob({
		interval = 30,
		proc_chance = 0.3,
		spawn_id = 'black_bat',
		spawn_type = 'circle', 
		spawn_size = 6,
		spawn_options = { radius = 15, duration = 40 },
	}))

	#all
	event_system.add({
	  "type": "data_increment", "start": "02:00", "interval": "01:00", "timeout": "15:00",
	  "data": { "level": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "15:00", "interval": "00:02",
	  "data": { "level": 5 }
	})


func _set_level_2():
	# bat
	event_system.add({
	  "type": "spawn", "interval": 1,
	  "data": {
		"min_enemies_alive": 8,
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "bat", "size": 1, "max_alive": 10 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "01:00", "ticks": 8,
	  "data": { "id": "bat", "spawn_data": { "stats": { "base_damage": 1 } } }
	})
	event_system.add({
	  "type": "data_increment", "start": "00:30", "interval": "01:00", "ticks": 6,
	  "data": { "id": "bat", "size": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "00:20", "interval": "00:20",
	  "data": { "id": "bat", "max_alive": 1 }
	})

	# bat king
	event_system.add({
	  "type": "spawn", "start": "01:00", "interval": 15,
	  "data": {
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "bat_king", "size": 1, "max_alive": 1 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "02:00", "interval": "02:00", "ticks": 4,
	  "data": { "id": "bat_king", "max_alive": 1 }
	})

	# ghost
	event_system.add({
	  "type": "spawn", "start": "02:00", "interval": 2,
	  "data": {
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "ghost", "size": 1, "max_alive": 1 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "02:00", "interval": "01:30",
	  "data": { "id": "ghost", "max_alive": 1 }
	})

	# mob black_bat
	event_system.add(Global.event_create_mob({
		interval = 30,
		proc_chance = 0.5,
		spawn_id = 'black_bat',
		spawn_type = 'circle', 
		spawn_size = 14,
		spawn_options = { radius = 15, duration = 40 },
	}))

	# all
	event_system.add({
	  "type": "data_increment", "start": "02:00", "interval": "00:50", "timeout": "10:00",
	  "data": { "level": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "10:00", "interval": "00:02",
	  "data": { "level": 10 }
	})


func _set_level_3():
	# bat
	event_system.add({
	  "type": "spawn", "interval": 1,
	  "data": {
		"min_enemies_alive": 12,
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "bat", "size": 1, "max_alive": 10 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "01:00", "ticks": 8,
	  "data": { "id": "bat", "spawn_data": { "stats": { "base_damage": 1 } } }
	})
	event_system.add({
	  "type": "data_increment", "start": "00:30", "interval": "00:50", "ticks": 7,
	  "data": { "id": "bat", "size": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "00:20", "interval": "00:20",
	  "data": { "id": "bat", "max_alive": 1 }
	})

	# bat king
	event_system.add({
	  "type": "spawn", "start": "01:00", "interval": 15,
	  "data": {
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "bat_king", "size": 1, "max_alive": 1 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "02:00", "ticks": 5,
	  "data": { "id": "bat_king", "max_alive": 1 }
	})

	# ghost
	event_system.add({
	  "type": "spawn", "start": "02:00", "interval": 2,
	  "data": {
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "ghost", "size": 1, "max_alive": 1 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "02:00", "interval": "01:30",
	  "data": { "id": "ghost", "max_alive": 1 }
	})

	# eye
	event_system.add({
	  "type": "spawn", "start": "02:00", "interval": 2,
	  "data": {
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "eye", "size": 1, "max_alive": 1 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "03:00", "interval": "01:30",
	  "data": { "id": "eye", "max_alive": 1 }
	})

	# book
	event_system.add({
	  "type": "spawn", "start": "02:00", "interval": 2,
	  "data": {
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "book", "size": 1, "max_alive": 1 }]
	  }
	})
	event_system.add({
		"type": "data_increment", "start": "03:00", "interval": "02:30", "ticks": 3,
		"data": { "id": "book", "max_alive": 1 }
	})

	# mob ghost
	event_system.add(Global.event_create_mob({
		interval = 30, proc_chance = 0.6, spawn_id = 'ghost', spawn_type = 'column_left', 
	}))
	event_system.add(Global.event_create_mob({
		interval = 30, proc_chance = 0.6, spawn_id = 'ghost', spawn_type = 'column_right', 
	}))
	event_system.add(Global.event_create_mob({
		interval = 30, proc_chance = 0.6, spawn_id = 'ghost', spawn_type = 'row_top', 
	}))
	event_system.add(Global.event_create_mob({
		interval = 30, proc_chance = 0.6, spawn_id = 'ghost', spawn_type = 'row_bottom', 
	}))

	# mob black_bat
	event_system.add(Global.event_create_mob({
		interval = 30,
		proc_chance = 0.8,
		spawn_id = 'black_bat',
		spawn_type = 'circle', 
		spawn_size = 20,
		spawn_options = { radius = 15, duration = 40 },
	}))

	# all
	event_system.add({
	  "type": "data_increment", "start": "02:00", "interval": "00:40", "timeout": "10:00",
	  "data": { "level": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "10:00", "interval": "00:02",
	  "data": { "level": 15 }
	})

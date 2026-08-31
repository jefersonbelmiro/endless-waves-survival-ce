extends MapBase


const spawn_data = {
	"jelly": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 10 },
		"consumable_tier_1": { "proc_chance": 0.01 }
	  }
	},
	"jelly_king": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 50 },
		"consumable_tier_2": { "proc_chance": 0.01 }
	  }
	},
	"eye": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 20 },
		"consumable_tier_1": { "proc_chance": 0.01 }
	  }
	},
	"bat": {
	  "drops": {
		"coin": { "proc_chance": 0.05 },
		"experience": { "proc_chance": 0.8, "value": 10 },
		"consumable_tier_1": { "proc_chance": 0.01 }
	  },
	  "collision_layer": ["ghost"],
	  "collision_mask": ["ghost", "env"]
	},
	"green_caterpillar": {
	  "drops": {
		"coin": { "proc_chance": 0.2 },
		"experience": { "proc_chance": 0.8, "value": 10 },
		"consumable_tier_1": { "proc_chance": 0.01 }
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
	Global.event_add_reaper(event_system, { start = '15:00' })


func _set_level_1():
	# jelly
	event_system.add({
		"type": "spawn", "interval": 1,
		"data": {
			"min_enemies_alive": 10,
			"spawn_mode": "map_bounds",
			"spawns": [{ "id": "jelly", "size": 2, "max_alive": 10 }]
		}
	})
	event_system.add({
		"type": "data_increment", "start": "01:00", "interval": "00:20",
		"data": { "id": "jelly", "size": 1 }
	})
	event_system.add({
		"type": "data_increment", "start": "00:40", "interval": "00:20",
		"data": { "id": "jelly", "max_alive": 1 }
	})

	# jelly king
	event_system.add({
		"type": "spawn", "start": "01:00", "interval": 2,
		"data": {
			"spawn_mode": "map_bounds",
			"spawns": [{ "id": "jelly_king", "size": 1, "max_alive": 1 }]
		}
	})
	event_system.add({
		"type": "data_increment", "start": "02:00", "interval": "02:00",
		"data": { "id": "jelly_king", "max_alive": 1 }
	})

	# jelly boss
	event_system.add({
		"type": "spawn", 
		"start": "02:00",
		"interval": "05:00",
		"data": {
			"spawn_mode": "map_bounds",
			"spawns": [{ 
				"id": "jelly_boss", 
				"size": 1,
				"max_alive": 1,
				"data": {
					"level": 1,
					"stats": {
						"move_speed": 30,
						"max_health": 500,
						"base_damage": 10,
						"status_resistance": 0.5,
						"attack_speed": 40
					},
					"drops": {
						"coin": { "proc_chance": 1.0, "value": 10 },
						"experience": { "proc_chance": 1.0, "value": 200 },
						"consumable_tier_3": { "proc_chance": 1.0 },
					}
				}
			}]
		}
	})

	# all
	event_system.add({
		"type": "data_increment",
		"start": "02:00",
		"interval": "00:20",
		"timeout": "10:00",
		"data": { "level": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "10:00",
	  "interval": "00:02",
	  "data": { "level": 5 }
	})


func _set_level_2():
	event_system.set_spawn_mode({ "mode": "circle", "center_position": Vector2(230, 130), "radius": 220, })

	# jelly
	event_system.add({
		"type": "spawn", "interval": 1,
		"data": { 
			"min_enemies_alive": 10,
			"spawns": [{ "id": "jelly", "size": 2, "max_alive": 10 }]
		}
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "00:20",
	  "data": { "id": "jelly", "size": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "00:10", "interval": "00:20",
	  "data": { "id": "jelly", "max_alive": 1 }
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
	  "type": "data_increment", "start": "05:00", "interval": "01:00",
	  "data": { "id": "eye", "max_alive": 1 }
	})

	# jelly king
	event_system.add({
	  "type": "spawn", "start": "01:00", "interval": 2,
	  "data": {
		"spawn_mode": "map_bounds",
		"spawns": [{ "id": "jelly_king", "size": 1, "max_alive": 1 }]
	  }
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "01:00",
	  "data": { "id": "jelly_king", "max_alive": 1 }
	})

	# jelly boss
	event_system.add({
		"type": "spawn", 
		"start": "04:00",
		"interval": "05:00",
		"data": {
			"spawn_mode": "map_bounds",
			"spawns": [{ 
				"id": "jelly_boss", 
				"size": 1,
				"max_alive": 1,
				"data": {
					"level": 2,
					"stats": {
						"move_speed": 20,
						"max_health": 1000,
						"base_damage": 10,
						"status_resistance": 0.5,
						"attack_speed": 30
					}
				}
			}]
		}
	})

	# all
	event_system.add({
	  "type": "data_increment",
	  "start": "01:00",
	  "interval": "00:20",
	  "timeout": "15:00",
	  "data": { "level": 1 }
	})
	event_system.add({
	  "type": "data_increment",
	  "start": "15:00",
	  "interval": "00:02",
	  "data": { "level": 10 }
	})


func _set_level_3():
	event_system.set_spawn_mode({ "mode": "circle", "center_position": Vector2(230, 130), "radius": 220, })

	# jelly
	event_system.add({
	  "type": "spawn", "interval": 1,
	  "data": { 
		  "min_enemies_alive": 10,
		  "spawns": [{ "id": "jelly", "size": 2, "max_alive": 10 }] }
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "00:20",
	  "data": { "id": "jelly", "size": 1 }
	})
	event_system.add({
	  "type": "data_increment", "start": "00:10", "interval": "00:20",
	  "data": { "id": "jelly", "max_alive": 1 }
	})

	# green caterpillar
	event_system.add({
	  "type": "spawn", "start": "03:00", "interval": 3,
	  "data": { "spawns": [{ "id": "green_caterpillar", "size": 1, "max_alive": 5 }] }
	})
	event_system.add({
	  "type": "data_increment", "start": "03:00", "interval": "01:00",
	  "data": { "id": "eye", "max_alive": 1 }
	})


	# eye
	event_system.add({
	  "type": "spawn", "start": "02:00", "interval": 2,
	  "data": { "spawns": [{ "id": "eye", "size": 1, "max_alive": 1 }] }
	})
	event_system.add({
	  "type": "data_increment", "start": "03:00", "interval": "01:00",
	  "data": { "id": "eye", "max_alive": 1 }
	})

	# bat
	event_system.add({
	  "type": "spawn", "start": "03:00", "interval": 2,
	  "data": { "spawns": [{ "id": "bat", "size": 1, "max_alive": 1 }] }
	})
	event_system.add({
	  "type": "data_increment", "start": "04:00", "interval": "01:00",
	  "data": { "id": "bat", "max_alive": 1 }
	})

	# jelly king
	event_system.add({
	  "type": "spawn", "start": "01:00", "interval": 2,
	  "data": { "spawns": [{ "id": "jelly_king", "size": 1, "max_alive": 2 }] }
	})
	event_system.add({
	  "type": "data_increment", "start": "01:00", "interval": "01:00",
	  "data": { "id": "jelly_king", "max_alive": 1 }
	})

	# jelly boss
	event_system.add({
		"type": "spawn",
		"start": "05:00",
		"interval": "05:00",
		"data": {
			"spawn_mode": "map_bounds",
			"spawns": [{ 
				"id": "jelly_boss", 
				"size": 1,
				"max_alive": 1,
				"data": {
					"level": 3,
					"stats": {
						"move_speed": 20,
						"max_health": 2000,
						"base_damage": 15,
						"status_resistance": 0.8,
						"attack_speed": 45
					}
				}
			}]
		}
	})

	# all
	event_system.add({
	  "type": "data_increment",
	  "start": "01:00",
	  "interval": "00:15",
	  "timeout": "20:00",
	  "data": { "level": 1 }
	})
	event_system.add({
	  "type": "data_increment",
	  "start": "20:00",
	  "interval": "00:02",
	  "data": { "level": 15 }
	})



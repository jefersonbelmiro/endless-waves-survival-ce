extends Reference

const DEFAULT_DROP = {
	"coin": { "proc_chance": 0.2 },
	"experience": { "proc_chance": 0.8, "value": 10 },
	"consumable": { "proc_chance": 0.01 }
}
const CHEST_ROOM_INTERVAL = 3
const CHEST_ROOM_PROC_CHANCE = 0.2

var tier_data = null
var last_event_data = null
var map
var room_manager

var chest_room_index = CHEST_ROOM_INTERVAL

func _init(map_, room_manager_):
	map = map_
	room_manager = room_manager_
	randomize()


func process():
	var is_last_room = false if map.data.mode == Global.MAP_MODES.ENDLESS else room_manager.current_room_index + 1 >= room_manager.total_rooms
	if !is_last_room && chest_room_index <= 0 && randf() <= CHEST_ROOM_PROC_CHANCE:
		chest_room_index = CHEST_ROOM_INTERVAL
		return _process_chest_room()
	chest_room_index -= 1

	match room_manager.current_room_index + 1:
		1, 2, 3, 4: return _process_room_tier(1)
		5, 6, 7, 8: return _process_room_tier(2)
		9, 10, 11, 12: return _process_room_tier(3)
		13: return _process_room_tier(4)
		_: return _process_room_tier(5)


func _process_chest_room():
	var chest_room_data = room_manager.get_room_data("chest") 
	var chest_position = chest_room_data.size * 8 + Vector2(-32, 4)
	var merchant_position = chest_room_data.size * 8 + Vector2(64, 4)
	return {
		room = room_manager.get_room_data("chest"),
		objectives = [],
		spawn_data = {},
		events = [
			{ 
				type = 'spawn', 
				data = {
					spawn_animation = false,
					spawns = [
						{ id = 'chest', type = 'drop', position = chest_position, data = { value = room_manager.current_room_index + 1 } },
						{ id = 'merchant', type = 'npc', position =  merchant_position },
					]
				}
			}
		],
	}


func _create_debug_events():
	return {
		room = room_manager.get_room_data("small_square"),
		enemy_level = 1,
		events = [
			{
				spawns = [
					{ 
						id = 'skeleton', size = 1, interval = 2, min_enemies_alive = 4, max_enemies_alive = 8,
						data = { 
							stats = {
								move_speed = 200
							}
						}
					},
				],
			},
		],
	}


func _create_tier_1_events():
	return {
		room = room_manager.get_room_data("small_square"),
		enemy_level = 1,
		events = [
			{
				spawns = [
					{ id = 'jelly', size = 5 },
					{ id = 'jelly', size = 1, start = 3, interval = 2, min_enemies_alive = 5, max_enemies_alive = 10 },
				],
			},
			{
				spawns = [
					{ id = 'bat', size = 3 },
					{ id = 'bat', size = 1, start = 3, interval = 2, min_enemies_alive = 4, max_enemies_alive = 8 },
				],
			},
			{
				spawns = [
					{ id = 'skeleton', size = 4 },
					{ id = 'skeleton', size = 1, start = 3, interval = 2, min_enemies_alive = 4, max_enemies_alive = 8 },
				],
			},
		],
	}

func _create_tier_2_events():
	return {
		room = room_manager.get_room_data("small_square"),
		enemy_level = 2,
		events = [
			{
				spawns = [
					{ id = 'jelly', size = 4 },
					{ id = 'jelly_king', size = 3, start = 4 },
					{ id = 'jelly', size = 1, interval = 2, min_enemies_alive = 10, max_enemies_alive = 15 },
				],
			},
			{
				spawns = [
					{ id = 'skeleton', size = 4 },
					{ id = 'skeleton_king', size = 2, start = 2 },
					{ id = 'skeleton', size = 1, interval = 2, min_enemies_alive = 8, max_enemies_alive = 12 },
				],
			},
			{
				spawns = [
					{ id = 'bat', size = 4 },
					{ id = 'bat_king', size = 1, start = 2 },
					{ id = 'bat', size = 1, interval = 2, min_enemies_alive = 6, max_enemies_alive = 10 },
				],
			},
			{
				spawns = [
					{ id = 'bat', size = 4 },
					{ id = 'eye', size = 3, start = 4 },
					{ id = 'bat', size = 1, interval = 2, min_enemies_alive = 6, max_enemies_alive = 10 },
				],
			},
			{
				spawns = [
					{ id = 'jelly', size = 5 },
					{ id = 'eye', size = 2, start = 4 },
					{ id = 'jelly', size = 1, start = 2, interval = 2, min_enemies_alive = 10, max_enemies_alive = 15 },
				],
			},
			{
				spawns = [
					{ id = 'green_caterpillar', size = 5 },
					{ id = 'eye', size = 2, start = 4 },
					{ id = 'green_caterpillar', size = 1, start = 2, interval = 2, min_enemies_alive = 10, max_enemies_alive = 15 },
				],
			},
			{
				spawns = [
					{ id = 'red_caterpillar', size = 5 },
					{ id = 'red_caterpillar', size = 1, start = 2, interval = 3, min_enemies_alive = 5, max_enemies_alive = 15 },
					{ id = 'green_caterpillar', size = 1, start = 4, interval = 3, min_enemies_alive = 5, max_enemies_alive = 15 },
				],
			},
		]
	}


func _create_tier_3_events():
	return {
		room = room_manager.get_room_data("small_square"),
		max_enemies_alive = 20,
		enemy_level = 3,
		events = [
			{
				objectives = [ { type = "kill_enemies", id = "book", value = 3, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'book', size = 3 },
					{ id = 'eye', size = 2, start = 5, interval = 5, max_enemies_alive = 5 },
				],
			},
			{
				objectives = [ { type = "kill_enemies", id = "skeleton_king_range", value = 3, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'skeleton_king_range', size = 3 },
					{ id = 'skeleton', size = 1,  start = 3, interval = 3, min_enemies_alive = 5, },
				],
			},
			{
				objectives = [ { type = "kill_enemies", id = "jelly_king", value = 5, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'jelly_king', size = 5 },
				],
			},
			{
				spawns = [
					{ id = 'skeleton', size = 1, interval = 2, min_enemies_alive = 10, },
					{ id = 'skeleton_king_range', size = 1, max_alive = 1, interval = 5 },
					{ id = 'skeleton_bomb', size = 1, max_alive = 1, interval = 5 },
				],
			},
			{
				objectives = [ { type = "kill_enemies", id = "jelly_boss", value = 1, } ],
				spawns = [
					{ id = 'jelly', size = 1, start = 5, interval = 5, min_enemies_alive = 10, max_enemies_alive = 20, timeout = "02:00" },
					{ id = 'green_caterpillar', size = 1, start = 7, interval = 5, min_enemies_alive = 5, max_enemies_alive = 10, timeout = "02:00" },
					{ id = 'jelly_boss', size = 1, max_enemies_alive = 1 },
				],
			},
			{
				objectives = [ { type = "kill_enemies", id = "skeleton_boss", value = 1 } ],
				spawns = [
					{ id = 'skeleton', size = 1, start = 5, interval = 1, min_enemies_alive = 8, max_enemies_alive = 30, timeout = "02:00" },
					{ id = 'skeleton_boss', size = 1, max_enemies_alive = 1 },
				],
			},
		],
	}


func _create_tier_4_events():
	var big_room_data = room_manager.get_room_data("big_square")
	var big_room_center_position = big_room_data.size * 8 + Vector2(16, -80)
	return {
		room = big_room_data,
		enemy_level = 4,
		events = [
			{
				objectives = [ { type = "kill_enemies", id = "book", value = 3, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'book', size = 3 },
					{ id = 'eye', size = 2, start = 5, interval = 5, max_enemies_alive = 5 },
					{ id = 'green_caterpillar', start = 5, interval = 5, min_enemies_alive = 10, max_enemies_alive = 20 },
				],
			},
			{
				objectives = [ { type = "kill_enemies", id = "centipede_elite", value = 1, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'centipede_elite', position = big_room_center_position  },
					{ id = 'green_caterpillar', start = 5, interval = 5, min_enemies_alive = 10, max_enemies_alive = 20 },
				],
			},
			{
				objectives = [ { type = "kill_enemies", id = "centipede_elite", value = 1, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'centipede_elite', position = big_room_center_position  },
					{ id = 'red_caterpillar', start = 5, interval = 5, min_enemies_alive = 10, max_enemies_alive = 20 },
				],
			},
			{
				objectives = [ { type = "kill_enemies", id = "serpent_elite", value = 1, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'serpent_elite', position = big_room_center_position },
					{ id = 'ghost', start = 5, interval = 5, min_enemies_alive = 2, max_enemies_alive = 8, data = { z_index = 250 } },
				],
			},
		],
	}


func _create_tier_5_events():
	var big_room_data = room_manager.get_room_data("big_square")
	var big_room_center_position = big_room_data.size * 8 + Vector2(16, -80)
	return {
		room = room_manager.get_room_data("small_square"),
		events = [
			{
				room = big_room_data,
				objectives = [ { type = "kill_enemies", id = "centipede_elite", value = 1, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'centipede_elite', position = big_room_center_position  },
					{ id = 'green_caterpillar', start = 5, interval = 5, min_enemies_alive = 10, max_enemies_alive = 20 },
				],
			},
			{
				room = big_room_data,
				objectives = [ { type = "kill_enemies", id = "centipede_elite", value = 1, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'centipede_elite', position = big_room_center_position  },
					{ id = 'red_caterpillar', start = 5, interval = 5, min_enemies_alive = 10, max_enemies_alive = 20 },
				],
			},
			{
				room = big_room_data,
				objectives = [ { type = "kill_enemies", id = "serpent_elite", value = 1, label = "OBJECTIVE_KILL_ELITE" } ],
				spawns = [
					{ id = 'serpent_elite', position = big_room_center_position },
					{ id = 'ghost', start = 5, interval = 5, min_enemies_alive = 2, max_enemies_alive = 8, data = { z_index = 250 } },
				],
			},
			{
				spawns = [
					{ id = 'ghost', interval = 3, min_enemies_alive = 4, max_enemies_alive = 10 },
					{ id = 'book', start = 8, interval = 5, max_enemies_alive = 2 },
				],
			},
			{
				spawns = [
					{ id = 'bat', interval = 3, min_enemies_alive = 8, max_enemies_alive = 20 },
					{ id = 'ghost', start = 5, interval = 4, max_enemies_alive = 4 },
					{ id = 'book', start = 20, interval = 10, max_enemies_alive = 1 },
				],
			},
			{
				spawns = [
					{ id = 'jelly', interval = 2, min_enemies_alive = 5 },
					{ id = 'skeleton', interval = 3, min_enemies_alive = 5 },
					{ id = 'jelly_king', start = 10, interval = 8, min_enemies_alive = 2, max_enemies_alive = 5 },
					{ id = 'skeleton_king', start = 30, interval = 8, max_enemies_alive = 5 },
				],
			},
			{
				objectives = [ { type = "kill_enemies", id = "skeleton_boss", value = 1 } ],
				spawns = [
					{ id = 'skeleton', interval = 3, min_enemies_alive = 8, timeout = "02:00" },
					{ id = 'skeleton_king', start = 5, interval = 8, max_enemies_alive = 5, timeout = "02:00" },
					{ id = 'skeleton_boss', start = "01:00",  max_enemies_alive = 1 },
				],
			},
			{
				room = room_manager.get_room_data("horizontal") ,
				spawns = [
					{ id = 'skeleton', interval = 1, max_enemies_alive = 15 },
					{ id = 'bat', interval = 2, max_enemies_alive = 5 },
					{ id = 'ghost', interval = 5, max_enemies_alive = 5 },
				],
			},
			{
				room = room_manager.get_room_data("horizontal") ,
				spawns = [
					{ id = 'jelly', interval = 1, max_enemies_alive = 15 },
					{ id = 'red_caterpillar', interval = 3, max_enemies_alive = 10 },
					{ id = 'ghost', interval = 5, max_enemies_alive = 5 },
				],
			},
			{
				spawns = [
					{ id = 'skeleton', interval = 1, min_enemies_alive = 2, max_alive = 5 },
					{ id = 'skeleton_king_range', interval = 3, max_alive = 2 },
					{ id = 'skeleton_bomb', interval = 5, max_alive = 2 },
				],
			},
			{
				spawns = [
					{ id = 'red_caterpillar', interval = 2, min_enemies_alive = 5, max_enemies_alive = 20 },
					{ id = 'green_caterpillar', interval = 4, min_enemies_alive = 5, max_enemies_alive = 20 },
					{ id = 'skeleton_bomb', interval = 5, max_alive = 5 },
				],
			},
			{
				room = big_room_data,
				spawns = [
					{ id = 'ghost', interval = 1, min_enemies_alive = 2, max_alive = 5 },
					{ id = 'book', start = 20, interval = 10, max_enemies_alive = 2 },
				],
			},
			{
				room = big_room_data,
				spawns = [
					{ id = 'eye', interval = 1, min_enemies_alive = 3, max_alive = 10 },
					{ id = 'book', start = 20, interval = 10, max_enemies_alive = 5 },
				],
			},
			{
				room = big_room_data,
				objectives = [ { type = "kill_enemies", id = "jelly_boss", value = 1, } ],
				spawns = [
					{ id = 'jelly', size = 1, interval = 4, min_enemies_alive = 20, max_enemies_alive = 40, timeout = "02:00" },
					{ id = 'green_caterpillar', size = 1, start = 7, interval = 5, min_enemies_alive = 10, max_enemies_alive = 20, timeout = "02:00" },
					{ id = 'jelly_boss', start = 30, max_enemies_alive = 1 },
				],
			},
		],
	}


func _get_random_event_data():
	var is_last_room = false if map.data.mode == Global.MAP_MODES.ENDLESS else room_manager.current_room_index + 1 >= room_manager.total_rooms
	var events = tier_data.events

	if is_last_room && events.size() > 1:
		var boss_events = []
		for event_index in events.size():
			var event_data = events[event_index]
			if !'objectives' in event_data:
				continue
			for index in event_data.objectives.size():
				var objective = event_data.objectives[index]
				if objective.type == 'kill_enemies' and objective.value == 1:
					boss_events.append(event_data)
		if boss_events.size():
			events = boss_events

	var event_data = events[randi() % events.size()]

	# prevent same event, get next event index
	if event_data == last_event_data && events.size() > 1:
		var current_index = events.find(event_data)
		event_data = events[(current_index + 1) % events.size()]

	return event_data


func _process_room_tier(tier: int):
	if !tier_data || tier_data.tier != tier:
		tier_data = call("_create_tier_%s_events" % [tier])
		tier_data.tier = tier
	var total_size = (room_manager.current_room_index + 1) * 10
	var event_data = _get_random_event_data()

	last_event_data = event_data

	var spawn_data = {}
	var events = []
	var room = event_data.room if 'room' in event_data else tier_data.room
	var enemy_level = tier_data.enemy_level if 'enemy_level' in tier_data else (room_manager.current_room_index + 1) * 10
	if 'enemy_level' in event_data:
		enemy_level = event_data.enemy_level

	var min_enemies_alive = tier_data.min_enemies_alive if 'min_enemies_alive' in tier_data else 1
	if 'min_enemies_alive' in event_data:
		min_enemies_alive = event_data.min_enemies_alive
	var max_enemies_alive = tier_data.max_enemies_alive if 'max_enemies_alive' in tier_data else max(tier * 10, 150)
	if 'max_enemies_alive' in event_data:
		max_enemies_alive = event_data.max_enemies_alive

	if 'waves' in event_data:
		var event = {
			type = "spawn_wave",
			data = {
				max_enemies_alive = tier_data.max_enemies_alive,
				spawns = [],
			}
		}
		if 'start' in event_data: 
			event.start = event_data.start
		if 'timeout' in event_data: 
			event.timeout = event_data.timeout
		if 'ticks' in event_data: 
			event.ticks = event_data.ticks
		if 'interval' in event_data: 
			event.interval = event_data.interval
		for index in event_data.waves.size():
			var item = event_data.waves[index]
			var enemy_spawn_data = { id = item.id, size = 1, level = enemy_level }
			if "size" in item:
				enemy_spawn_data.size = item.size
			if 'position' in item:
				enemy_spawn_data.position = item.position
			if 'level' in item:
				enemy_spawn_data.level = item.leve

			var enemy_data = { level = enemy_level }
			if "level" in item:
				enemy_data.level = item.level
			if "data" in item:
				enemy_data = FP.patch_dictionary(enemy_data, item.data)

			event.data.spawns.append({ id = item.id, size = item.size, })
			_set_spawn_data(item.id, spawn_data, enemy_data)
		events.append(event)

	if 'spawns' in event_data:
		for index in event_data.spawns.size():
			var item = event_data.spawns[index]
			var enemy_spawn_data = { id = item.id, size = 1 }

			if "size" in item:
				enemy_spawn_data.size = item.size

			var spawn_min_enemies_alive = item.min_enemies_alive if 'min_enemies_alive' in item else min_enemies_alive
			if spawn_min_enemies_alive > 1:
				spawn_min_enemies_alive += int(tier / 5.0)
			var spawn_max_enemies_alive = item.max_enemies_alive if 'max_enemies_alive' in item else max_enemies_alive
			if spawn_max_enemies_alive > 1:
				spawn_max_enemies_alive += int(tier / 3.0)
			if 'max_alive' in item:
				enemy_spawn_data.max_alive = item.max_alive
			if 'position' in item:
				enemy_spawn_data.position = item.position

			var enemy_data = { level = enemy_level }
			if "level" in item:
				enemy_data.level = item.level
			if "data" in item:
				enemy_data = FP.patch_dictionary(enemy_data, item.data)

			var event = {
				type = "spawn",
				data = {
					min_enemies_alive = spawn_min_enemies_alive,
					max_enemies_alive = spawn_max_enemies_alive,
					spawns = [enemy_spawn_data],
				}
			}
			if 'start' in item: 
				event.start = item.start
			if 'timeout' in item: 
				event.timeout = item.timeout
			if 'ticks' in item: 
				event.ticks = item.ticks
			if 'interval' in item: 
				event.interval = item.interval
			events.append(event)
			_set_spawn_data(item.id, spawn_data, enemy_data)

	var objectives = [
		{ type = "kill_enemies", value = total_size }
	]
	if 'objectives' in event_data:
		objectives = event_data.objectives

	if tier >= 5:
		events.append(Global.event_create_reaper({ 
			start = "01:00",
			spawn_data = {
				collision_mask = ["env"],
				rush_attack_collision_mask = ['env'],
				teleport_check_map_bounds = true,
			}
		}))

	return {
		objectives = objectives,
		spawn_data = spawn_data,
		events = events,
		room = room,
	}


func _set_spawn_data(id: String, spawn_data: Dictionary, patch_data = null):
	if id in spawn_data:
		return false
	var data = { drops = DEFAULT_DROP.duplicate() }
	if patch_data:
		data = FP.patch_dictionary(data, patch_data)
	match id:
		"jelly_king", "skeleton_king": 
			data.behaviours = [
				"chase",
				"knockback",
				{
					id =  "melee_attack",
					data = { damage_knockback = 100 }
				},
				{
					id = "rush_attack",
					data = {
						attack_range = 100,
						proc_chance = 0.6,
						collision_mask = ["env"],
				  }
				}
			]
	spawn_data[id] = data
	return true

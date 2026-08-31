extends Node

export var spawn_mode = 'map_bounds'
export var max_enemies_alive: int = 100
export var min_enemies_alive: int = 1
export var max_spawn_size: int = 0
export var enemy_level_over_kills = true
export var enemy_inc_level_at_kills: int = 100
export var auto_start = true

var respawn_factor: float = 0.0

# if export, keep reference betwen instances created/freed
# i thing Godot use references objects exported like Resource
# and using add() just append, keeping growing wrong
var events = []

var _next_event_id = 0
var _current_events = []
var _spawn_events = []
var _timer_container: Node

var _enemy_level_inc = {}
var _enemy_kills: int = 0
var _kill_rate_size: int = 0
var _kill_rates = []
var _kill_rate: float = 0.0
var _kill_rates_size = 12
var _kill_rate_interval: float = 5.0
var _trait_spawn_factor := 0.0

onready var map = get_parent()


func _ready():
	if auto_start:
		Global.connect("player_spawned", self, "start")
	_timer_container = Node.new()
	add_child(_timer_container)
	_trait_spawn_factor = Traits.get_spawn_factor()


## Add event
##[codeblock]
##event = {
##  type: String			"spawn" | "data_increment"
##  start: Int | String		ms or mm:ss  
##  interval: Int | String	ms or mm:ss 
##  timeout: Int | String	ms or mm:ss  
##  ticks: Int				total number of iterations the event will have
##	data: Dictionary		Event data
##}
##[/codeblock]
func add(event):
	events.append(event)


## set spawn mode
##[codeblock]
##mode: "map_bounds" | { "mode": "circle", "center_position": Vector2  | Array, radius: float }
##[/codeblock]
func set_spawn_mode(mode):
	spawn_mode = mode 


func start():
	var calculate_rate = respawn_factor > 0
	for index in events.size():
		var event = events[index].duplicate(true)

		event.id = _next_event_id
		_next_event_id += 1

		if !calculate_rate && 'respawn_factor' in event.data && event.data.respawn_factor > 0:
			calculate_rate = true
		
		# sanitize event data
		if event.type == 'spawn' || event.type == 'spawn_wave':
			_spawn_events.append(event)

			# use default spawn mode if current event dont have
			if !'spawn_mode' in event.data:
				event.data.spawn_mode = spawn_mode

			if event.type == 'spawn_wave':
				event.data._wave_index = 0

			for spawn in event.data.spawns:
				if !calculate_rate && 'respawn_factor' in spawn && spawn.respawn_factor > 0:
					calculate_rate = true

				if typeof(event.data.spawn_mode) == TYPE_STRING:
					event.data.spawn_mode = {
						mode = event.data.spawn_mode,
					}
				else:
					if 'center_position' in event.data.spawn_mode && typeof(event.data.spawn_mode.center_position) == TYPE_ARRAY:
						event.data.spawn_mode.center_position = Vector2(
							event.data.spawn_mode.center_position[0], 
							event.data.spawn_mode.center_position[1]
						)
						
				if !'size' in spawn:
					spawn.size = 1
				if !'type' in spawn:
					spawn.type = 'enemy'

				var spawn_data = spawn.data if 'data' in spawn else null
				spawn.data = map.get_spawn_data(spawn.id, spawn_data, spawn.type)

		event.current_tick = 0
		if !'ticks' in event:
			event.ticks = 0

		if !'start' in event && 'interval' in event:
			_create_interval_timer(event)
		elif 'start' in event:
			_create_start_timer(event)
		else:
			# just invoke, may have ticks may not
			_on_interval_timer_timeout(event)
			_current_events.erase(event)
		if 'timeout' in event:
			_create_timout_timer(event)

	if calculate_rate:
		_create_calculate_rate_timer()
	if calculate_rate || enemy_level_over_kills:
		Global.connect("enemy_died", self, '_on_enemy_died')


func clear(options = null):
	events = []
	reset(options)


# stop all event timers
func stop():
	if Global.is_connected("enemy_died", self, '_on_enemy_died'):
		Global.disconnect("enemy_died", self, '_on_enemy_died')
	Global.node_remove_children(_timer_container)


# reset all internal variables to start again safely
func reset(options = null):
	var keep_rates = FP.safe_get(options, 'keep_rates', false)
	stop()
	_current_events = []
	_spawn_events = []
	if !keep_rates:
		_enemy_level_inc = {}
		_kill_rates = []
		_kill_rate_size = 0
		_kill_rate = 0.0


func _create_start_timer(event):
	var start_time = Formatter.format_timer_seconds(event.start) 
	if start_time <= 0:
		_on_start_timer_timeout(event)
		return
	var node = Timer.new()
	node.autostart = true
	node.one_shot = true
	node.wait_time = start_time
	node.connect("timeout", self, '_on_start_timer_timeout', [event])
	event.start_timer = node
	_timer_container.add_child(node)


func _create_timout_timer(event):
	var node = Timer.new()
	node.autostart = true
	node.one_shot = true
	node.wait_time = Formatter.format_timer_seconds(event.timeout)
	event.timeout_timer = node
	node.connect("timeout", self, '_on_timout_timer_timeout', [event])
	_timer_container.add_child(node)


func _create_interval_timer(event):
	var node = Timer.new()
	node.autostart = true
	node.wait_time = Formatter.format_timer_seconds(event.interval)
	node.connect("timeout", self, '_on_interval_timer_timeout', [event])
	event.interval_timer = node
	if event.type == "spawn":
		_current_events.append(event)
	_timer_container.add_child(node)
	# first call, dont wait interval
	_on_interval_timer_timeout(event)


func _process_event(event):
	if 'proc_chance' in event && event.proc_chance < 1.0 && randf() > event.proc_chance:
		return
	event.current_tick += 1
	if event.type == 'spawn':
		_spawn(event)
	elif event.type == 'spawn_wave':
		_spawn_wave(event)
	elif event.type == 'data_increment':
		_data_increment(event)
	if event.ticks && event.current_tick >= event.ticks:
		_stop_event(event)


func _spawn(event):
	var nodes = []
	var spawn_animation = true
	if 'spawn_animation' in event.data:
		spawn_animation = event.data.spawn_animation

	var event_group_id = "spawn_event_%s" % [event.id]

	for index in event.data.spawns.size():
		var spawn = event.data.spawns[index]
		var spawn_size = spawn.size
		var current_targets_length = Targets.nodes.size()

		var current_enemies_length = current_targets_length
		var current_respawn_factor = _get_respawn_factor(spawn, event)
		var current_min_enemies_alive = _get_min_enemies_alive(spawn, event)
		var current_max_enemies_alive = _get_max_enemies_alive(spawn, event)
		var current_max_spawn_size = _get_max_spawn_size(spawn, event)

		if 'max_alive' in spawn:
			current_enemies_length = get_tree().get_nodes_in_group(spawn.id).size() 
			current_max_enemies_alive = spawn.max_alive
		elif 'min_enemies_alive' in spawn || 'max_enemies_alive' in spawn:
			current_enemies_length = get_tree().get_nodes_in_group(spawn.id).size() 
		elif 'min_enemies_alive' in event.data || 'max_enemies_alive' in event.data:
			current_enemies_length = get_tree().get_nodes_in_group(event_group_id).size()

		if current_respawn_factor:
			spawn_size += round(current_respawn_factor * _kill_rate)

		if spawn.type == 'enemy':
			if _trait_spawn_factor:
				spawn_size += round(spawn_size * _trait_spawn_factor)

			if map.data.level > 1:
				spawn_size += round(spawn_size * map.data.level)

		var min_size = current_min_enemies_alive - current_enemies_length
		var max_size = current_max_enemies_alive - current_enemies_length
		spawn_size = clamp(spawn_size, min_size, max_size)

		if current_max_spawn_size:
			spawn_size = min(spawn_size, current_max_spawn_size)

		spawn_size = min(spawn_size, max_enemies_alive - current_targets_length)

		for _size_index in spawn_size:
			var scene = Global.spawn_id_scene[spawn.id]
			var node = scene.instance()
			if 'data' in node:
				node.data = spawn.data.duplicate(true)
				_set_enemy_level_inc(node)
			if 'spawn_animation' in node:
				node.spawn_animation = spawn_animation
			if 'position' in spawn:
				node.global_position = spawn.position
			else:
				nodes.append(node)
			node.add_to_group(spawn.id)
			node.add_to_group(event_group_id)
			Global.add_entity_deferred(node)

	if !nodes.size():
		return

	if event.data.spawn_mode.mode == 'circle':
		var position = Global.player.global_position
		var radius = 0 
		if 'center_position' in event.data.spawn_mode:
			position = event.data.spawn_mode.center_position
		if 'radius' in event.data.spawn_mode:
			radius = event.data.spawn_mode.radius
		map.set_positions_circle(nodes, position, radius)
	if event.data.spawn_mode.mode == 'outside_map_bounds':
		var options = event.data.spawn_mode.options if 'options' in event.data.spawn_mode else null
		map.set_positions_outside_map_bounds(nodes, options)
	else:
		map.set_positions_map_bounds(nodes)


func _spawn_wave(event):
	var nodes = []

	var spawn_animation = true
	if 'spawn_animation' in event.data:
		spawn_animation = event.data.spawn_animation

	var spawn = event.data.spawns[event.data._wave_index]

	if spawn.size <= 0 && event.data._wave_index + 1 < event.data.spawns.size():
		event.data._wave_index += 1
		spawn = event.data.spawns[event.data._wave_index]
	elif spawn.size <= 0 && event.data._wave_index + 1 >= event.data.spawns.size():
		return _stop_event(event)

	var spawn_size = spawn.size
	var current_enemies_length = Targets.nodes.size()
	var current_min_enemies_alive = _get_min_enemies_alive(spawn, event)
	var current_max_enemies_alive = _get_max_enemies_alive(spawn, event)
	var current_max_spawn_size = _get_max_spawn_size(spawn, event)

	if 'max_alive' in spawn:
		var current_id_length = get_tree().get_nodes_in_group(spawn.id).size()
		if current_id_length >= spawn.max_alive:
			return
		spawn_size = min(spawn_size, spawn.max_alive - current_id_length)

	var min_size = current_min_enemies_alive - current_enemies_length
	var max_size = current_max_enemies_alive - current_enemies_length
	spawn_size = clamp(spawn_size, min_size, max_size)

	if current_max_spawn_size:
		spawn_size = min(spawn_size, current_max_spawn_size)

	spawn.size -= spawn_size

	for _size_index in spawn_size:
		var scene = Global.spawn_id_scene[spawn.id]
		var node = scene.instance()
		node.data = spawn.data
		node.spawn_animation = spawn_animation
		node.add_to_group(spawn.id)
		nodes.append(node)
		Global.add_entity_deferred(node)

	if !nodes.size():
		return

	if event.data.spawn_mode.mode == 'circle':
		var position = Global.player.global_position
		var radius = 0 
		if 'center_position' in event.data.spawn_mode:
			position = event.data.spawn_mode.center_position
		if 'radius' in event.data.spawn_mode:
			radius = event.data.spawn_mode.radius
		map.set_positions_circle(nodes, position, radius)
	else:
		map.set_positions_map_bounds(nodes)


func _data_increment(event):
	if 'size' in event.data:
		for current_event in _current_events:
			for spawn in current_event.data.spawns:
				if 'id' in event.data && !_has_id(event.data, 'id', spawn.id):
					continue
				if 'ignore_id' in event.data && _has_id(event.data, 'ignore_id', spawn.id):
					continue
				spawn.size += event.data.size
				# turn off event
				if max_spawn_size && spawn.size >= max_spawn_size:
					spawn.size = max_spawn_size
					_stop_event(event)

	if 'max_alive' in event.data:
		for current_event in _current_events:
			for spawn in current_event.data.spawns:
				if 'id' in event.data && !_has_id(event.data, 'id', spawn.id):
					continue
				if 'ignore_id' in event.data && _has_id(event.data, 'ignore_id', spawn.id):
					continue
				spawn.max_alive += event.data.max_alive
				# turn off event
				if max_enemies_alive && spawn.max_alive >= max_enemies_alive:
					spawn.max_alive = max_enemies_alive
					_stop_event(event)

	if 'level' in event.data:
		for current_event in _current_events:
			for spawn in current_event.data.spawns:
				if 'id' in event.data && !_has_id(event.data, 'id', spawn.id):
					continue
				if 'ignore_id' in event.data && _has_id(event.data, 'ignore_id', spawn.id):
					continue
				if 'level' in spawn.data:
					spawn.data.level += event.data.level

	if 'drops_proc_chance' in event.data:
		for current_event in _current_events:
			for spawn in current_event.data.spawns:
				if 'id' in event.data && !_has_id(event.data, 'id', spawn.id):
					continue
				if 'ignore_id' in event.data && _has_id(event.data, 'ignore_id', spawn.id):
					continue
				for id in event.data.drops_proc_chance.keys():
					var drop_data = event.data.drops_proc_chance[id]
					if !'drops' in spawn.data || !spawn.data.drops.has(id):
						continue
					spawn.data.drops[id].proc_chance += drop_data.proc_chance
					if spawn.data.drops[id].proc_chance < 0:
						spawn.data.drops[id].proc_chance = 0

	if 'spawn_data' in event.data:
		for index in _spawn_events.size():
			for spawn_index in _spawn_events[index].data.spawns.size():
				var spawn_event = _spawn_events[index].data.spawns[spawn_index]
				if 'id' in event.data && !_has_id(event.data, 'id', spawn_event.id):
					continue
				if 'ignore_id' in event.data && _has_id(event.data, 'ignore_id', spawn_event.id):
					continue
				spawn_event.data = FP.increment_dictionary(spawn_event.data, event.data.spawn_data)


func _get_max_spawn_size(spawn, event):
	if 'max_spawn_size' in spawn:
		return spawn.max_spawn_size
	if 'max_spawn_size' in event.data:
		return event.data.max_spawn_size
	return max_spawn_size


func _get_min_enemies_alive(spawn, event):
	if 'min_enemies_alive' in spawn:
		return spawn.min_enemies_alive
	if 'min_enemies_alive' in event.data:
		return event.data.min_enemies_alive
	return min_enemies_alive


func _get_max_enemies_alive(spawn, event):
	if 'max_enemies_alive' in spawn:
		return spawn.max_enemies_alive
	if 'max_enemies_alive' in event.data:
		return event.data.max_enemies_alive
	return max_enemies_alive


func _get_respawn_factor(spawn, event):
	if 'respawn_factor' in spawn:
		return spawn.respawn_factor
	if 'respawn_factor' in event.data:
		return event.data.respawn_factor
	return respawn_factor


func _on_interval_timer_timeout(event):
	_process_event(event)


func _on_start_timer_timeout(event):
	if 'start_timer' in event && is_instance_valid(event.start_timer):
		event.start_timer.queue_free()
	if 'interval' in event:
		_create_interval_timer(event)
	else:
		_current_events.erase(event)
		_process_event(event)
	

func _on_timout_timer_timeout(event):
	_stop_event(event)


func _stop_event(event):
	if 'interval_timer' in event:
		event.interval_timer.queue_free()
	if 'timeout_timer' in event:
		event.timeout_timer.queue_free()
	_current_events.erase(event)


func _has_id(data: Dictionary, key: String, id: String):
	var value = data[key]
	if typeof(value) != TYPE_ARRAY:
		value = [value]
	return value.has(id)


func _create_calculate_rate_timer():
	var node = Timer.new()
	node.name = 'calculate_rate_timer'
	node.autostart = true
	node.wait_time = _kill_rate_interval
	node.connect("timeout", self, '_on_calculate_rate_timer_timeout')
	_timer_container.add_child(node)


func _on_calculate_rate_timer_timeout():
	_kill_rates.append(_kill_rate_size/_kill_rate_interval)
	if _kill_rates.size() > _kill_rates_size:
		_kill_rates.pop_front()
	_kill_rate = FP.average(_kill_rates)
	_kill_rate_size = 0


func _on_enemy_died(enemy):
	_kill_rate_size += 1
	_enemy_kills += 1
	if enemy_level_over_kills && _enemy_kills % enemy_inc_level_at_kills == 0:
		if !enemy.data.id in _enemy_level_inc:
			_enemy_level_inc[enemy.data.id] = 0
		_enemy_level_inc[enemy.data.id] += 1


func _set_enemy_level_inc(node: Node):
	if !enemy_level_over_kills || !'level' in node.data:
		return
	if !'id' in node.data || !node.data.id in _enemy_level_inc:
		return
	var inc = _enemy_level_inc[node.data.id]
	if map.data.level > 1:
		inc += map.data.level
	node.data.level += inc

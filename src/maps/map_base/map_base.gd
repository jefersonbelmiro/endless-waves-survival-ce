extends Node
class_name MapBase

export var id: String

var data
var safe_zone = false

var _bounds
var _spawn_bounds
var _spawn_data = {}


onready var event_system = $event_system
onready var objective_system = $objective_system
onready var drop_system = $drop_system

func _ready():
	randomize()
	if data.mode == Global.MAP_MODES.OBJECTIVES:
		objective_system.objectives = data.get_objectives()
		objective_system.connect("completed", self, "_on_objectives_completed")

	if 'events' in data:
		event_system.events = data.events

	if 'spawn_mode' in data:
		event_system.spawn_mode = data.spawn_mode

	if 'max_enemies_alive' in data:
		event_system.max_enemies_alive = data.max_enemies_alive

	if 'max_spawn_size' in data:
		event_system.max_spawn_size = data.max_spawn_size

	if 'spawn_data'in data:
		for spawn_id in data.spawn_data.keys():
			_spawn_data[spawn_id] = get_spawn_data(spawn_id, data.spawn_data[spawn_id]) 

	var tile_bounds = get_node_or_null("tile_bounds")
	if tile_bounds:
		_bounds = calculate_bounds(tile_bounds)
		_spawn_bounds = _bounds.grow(-10)


func _on_objectives_completed():
	Global.emit_signal("objectives_completed")


func get_data():
	return data


func format_label():
	var mode = "OBJECTIVES"
	if data.mode == Global.MAP_MODES.ENDLESS:
		mode = "ENDLESS"
	return "%s / %s #%s" % [tr(data.label), tr(mode), data.level]


func get_camera_bounds(zoom: Vector2):
	var bounds = get_bounds()
	if bounds:
		bounds.position += zoom * 8
	return bounds


func get_bounds():
	return _bounds


func get_spawn_bounds():
	return _spawn_bounds


func get_spawn_center():
	return _spawn_bounds.get_center()


func spawn_bounds_has_point(point: Vector2):
	if !_spawn_bounds:
		return true
	return _spawn_bounds.has_point(point)


func get_wall_normal(position: Vector2):
	# use 4 Rect2, one for each wall
	# iterate to all 4 Rect2 and add to final result a normal for wall if collides
	var normal = Vector2()
	var top = Rect2()
	var right = Rect2()
	var bottom = Rect2()
	var left = Rect2()
	if top.has_point(position):
		normal += Vector2(0, 1)
	if right.has_point(position):
		normal += Vector2(-1, 0)
	if bottom.has_point(position):
		normal += Vector2(0, -1)
	if left.has_point(position):
		normal += Vector2(1, 0)
	return normal


func get_spawn_data(spawn_id: String, patch_value, type = "enemy"):
	if !_spawn_data.has(spawn_id):
		var enemy_data = {}
		if type == "enemy":
			enemy_data = Database.get_enemy(spawn_id).duplicate(true)
		elif type == "npc":
			enemy_data = Database.get_npc(spawn_id).duplicate(true)
		_spawn_data[spawn_id] = enemy_data
	if patch_value:
		return FP.patch_dictionary(_spawn_data[spawn_id], patch_value)
	return _spawn_data[spawn_id]


func set_spawn_data(spawn_id: String, patch_value):
	if !_spawn_data.has(spawn_id):
		_spawn_data[spawn_id] = Database.get_enemy(spawn_id).duplicate(true)
	_spawn_data[spawn_id] = FP.patch_dictionary(_spawn_data[spawn_id], patch_value)


func set_all_spawn_data(patch_values):
	for spawn_id in patch_values.keys():
		set_spawn_data(spawn_id, patch_values[spawn_id])


func clear_spawn_data():
	_spawn_data = {}


func calculate_bounds(tilemap):
	var cell_bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D(Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2())
	var margin_position = Vector2(tilemap.cell_size.x, tilemap.cell_size.y) + tilemap.global_position
	var margin_size = Vector2(tilemap.cell_size.x, tilemap.cell_size.y) * 2
	return Rect2(cell_to_pixel * cell_bounds.position  + margin_position, cell_to_pixel * cell_bounds.size - margin_size)


func get_positions_circle(center_position: Vector2, size: int, radius: int, angle = 360, check_bounds = true):
	var start_pos = Vector2(radius, 0).rotated(deg2rad(angle))
	var step = 2.0 * PI / max(size, 10)
	var positions = []
	for index in size:
		var position = center_position + start_pos.rotated(step * index)
		if  check_bounds && !spawn_bounds_has_point(position):
			continue
		positions.append(position)
	return positions


func get_position_circle_index(index: int, center_position: Vector2, size: int, radius: int): 
	var start_pos = Vector2(radius, 0)
	var step = 2.0 * PI /size
	var position = center_position + start_pos.rotated(step * index)
	if !spawn_bounds_has_point(position):
		return null
	return position


func get_random_position_bounds():
	var border = 32
	var x = rand_range(_spawn_bounds.position.x + border, _spawn_bounds.end.x - border)
	var y = rand_range(_spawn_bounds.position.y + border, _spawn_bounds.end.y - border)
	return Vector2(x, y)


func get_random_position_circle_bounds(center_position: Vector2, radius: float) -> Vector2:
	var position = center_position + (Vector2.ONE * rand_range(0, radius)).rotated(rand_range(0, PI))
	var x = clamp(position.x, _bounds.position.x, _bounds.end.x)
	var y = clamp(position.y, _bounds.position.y, _bounds.end.y)
	return Vector2(x, y)


func set_positions_circle(nodes: Array, center_position: Vector2, radius: float):
	if nodes.size() == 0:
		return
	if !radius:
		radius = rand_range(150, 200)
	var start_pos = Vector2(radius, 0).rotated(deg2rad(randi() % 360))
	var size = nodes.size()
	var step = 2 * PI / size
	var fails = []
	var sucess = []

	for index in size:
		var attempts = 20
		var inner_radius = 10
		var updated = false
		var position = center_position + start_pos.rotated(step * index)
		while !updated && attempts > 0:
			attempts -= 1
			if !spawn_bounds_has_point(position):
				inner_radius += 20
				if sucess.size() > 0:
					position = sucess[randi() % sucess.size()] + Vector2(inner_radius, 0).rotated(deg2rad(randi() % 360)) 
				else:
					position = center_position + Vector2(radius, 0).rotated(deg2rad(randi() % 360)).rotated(step * index) 
				continue
			nodes[index].global_position = position
			updated = true
			sucess.append(position)
		if !updated:
			fails.append(nodes[index])
		
	if fails.size():
		set_positions_map_bounds(fails)


func set_positions_map_bounds(nodes: Array):
	var border = 32
	var size = nodes.size()
	for index in size:
		var attempts = 10
		var found = false
		while attempts >= 0:
			attempts -= 1
			var x = rand_range(_spawn_bounds.position.x + border, _spawn_bounds.end.x - border)
			var y = rand_range(_spawn_bounds.position.y + border, _spawn_bounds.end.y - border)
			var position = Vector2(x, y)
			if position.distance_to(Global.player.global_position) < 30:
				continue
			if !spawn_bounds_has_point(position):
				continue
			nodes[index].global_position = position
			found =true
			break
		# not found, try one more time
		if !found:
			var x = rand_range(_spawn_bounds.position.x + border, _spawn_bounds.end.x - border)
			var y = rand_range(_spawn_bounds.position.y + border, _spawn_bounds.end.y - border)
			nodes[index].global_position = Vector2(x, y)
	


func set_positions_outside_map_bounds(nodes: Array, options = null):
	var min_range = options.min_range if options && 'min_range' in options else 0
	var max_range = options.max_range if options && 'max_range' in options else 10
	var bounds = options.bounds if options && 'bounds' in options else _spawn_bounds

	var sides = ["top", "right", "bottom", "left"]

	for index in nodes.size():
		var node = nodes[index]
		var side = sides[randi() % sides.size()]
		var x: float
		var y: float
		match side:
			"top":
				x = rand_range(bounds.position.x - max_range, bounds.end.x + max_range)
				y = bounds.position.y - rand_range(min_range, max_range) 
			"right":
				x = bounds.end.x + rand_range(min_range, max_range)  
				y = rand_range(bounds.position.y - max_range, bounds.end.y + max_range)
			"bottom":
				x = rand_range(bounds.position.x - max_range, bounds.end.x + max_range)
				y = bounds.end.y + rand_range(min_range, max_range) 
			"left":
				x = bounds.position.x - rand_range(min_range, max_range)  
				y = rand_range(bounds.position.y - max_range, bounds.position.y + max_range)
		var position = Vector2(x, y)
		node.global_position = position



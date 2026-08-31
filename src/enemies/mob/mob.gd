extends Node2D

enum SPAWN_TYPES { CIRCLE, COLUMN_LEFT, COLUMN_RIGHT, ROW_TOP, ROW_BOTTOM }

var id = 'mob'
var data
var stats = {
	move_speed = 0.0
}

var STATES = TargetBase.STATES
var state = STATES.SPAWNING
var direction = Vector2()
var velocity = Vector2()
var spawn_type
var spawn_effect_connected = false
var spawn_data
var spawn_nodes = []
var despawn_nodes_size = 0
var collide_with_abysm = false

onready var behaviour_container: BehaviourContainer = $behaviour_container
onready var timeout_timer = $timeout_timer


func _ready():
	set_physics_process(false)
	if !data.has('spawn_type') || !SPAWN_TYPES.keys().has(data.spawn_type.to_upper()):
		return push_error("Invalid mob spawn type: %s" % [data.spawn_type if 'spawn_type' in data else 'undefined'])
	if !data.has('spawn_id') || !data.spawn_id in Global.spawn_id_scene:
		return push_error("Invalid mob spawn id: %s" % [data.spawn_id if 'spawn_id' in data else 'undefined'])

	id = data.spawn_id
	spawn_type = SPAWN_TYPES.keys().find(data.spawn_type.to_upper())
	spawn_data = FP.merge_dictionary(Database.get("enemy_" + data.spawn_id), {
		level = data.spawn_level if 'spawn_level' in data else 1,
	})
	stats.move_speed = spawn_data.stats.move_speed

	if spawn_type == SPAWN_TYPES.CIRCLE:
		_spawn_circle()
	elif spawn_type == SPAWN_TYPES.COLUMN_LEFT:
		collide_with_abysm = true
		_spawn_column_left()
	elif spawn_type == SPAWN_TYPES.COLUMN_RIGHT:
		collide_with_abysm = true
		_spawn_column_right()
	elif spawn_type == SPAWN_TYPES.ROW_TOP:
		collide_with_abysm = true
		_spawn_row_top()
	elif spawn_type == SPAWN_TYPES.ROW_BOTTOM:
		collide_with_abysm = true
		_spawn_row_bottom()

	if 'spawn_options' in data && data.spawn_options && 'duration' in data.spawn_options:
		Global.delay_func(self, '_on_spawn_duration_timeout', data.spawn_options.duration)


func _physics_process(delta):
	if state == STATES.SPAWNING:
		return
	global_position += velocity * delta


func get_target():
	return Global.player

func is_disabled():
	return false

func _spawn_column_left():
	var map_bounds = Global.map.get_spawn_bounds()
	var margin_y = 20
	var margin = 12
	var rows = int(map_bounds.size.y / margin_y)
	
	var y = map_bounds.position.y + margin
	for index in rows:
		var target_position = Vector2(map_bounds.end.x + margin * 2, y) 
		var behavior = { id = "move_to_position", data = { position = target_position } }
		_spawn_scene(Vector2(map_bounds.position.x + margin, y), behavior)
		y += margin_y

	timeout_timer.start()


func _spawn_column_right():
	var map_bounds = Global.map.get_spawn_bounds()
	var margin_y = 20
	var margin = 12
	var rows = int(map_bounds.size.y / margin_y)

	var y = map_bounds.position.y + margin
	for index in rows:
		var target_position = Vector2(map_bounds.position.x - margin * 2, y) 
		var behavior = { id = "move_to_position", data = { position = target_position } }
		_spawn_scene(Vector2(map_bounds.end.x - margin, y), behavior)
		y += margin_y

	timeout_timer.start()


func _spawn_row_top():
	var map_bounds = Global.map.get_spawn_bounds()
	var margin_x = 20
	var margin = 12
	var columns = int(map_bounds.size.x / margin_x)

	var x = map_bounds.position.x + margin
	for index in columns:
		var target_position = Vector2(x, map_bounds.end.y + margin * 2) 
		var behavior = { id = "move_to_position", data = { position = target_position } }
		_spawn_scene(Vector2(x, map_bounds.position.y + margin), behavior)
		x += margin_x

	timeout_timer.start()


func _spawn_row_bottom():
	var map_bounds = Global.map.get_spawn_bounds()
	var margin_x = 20
	var margin = 12
	var columns = int(map_bounds.size.x / margin_x)

	var x = map_bounds.position.x + margin
	for index in columns:
		var target_position = Vector2(x, map_bounds.position.y - margin * 2) 
		var behavior = { id = "move_to_position", data = { position = target_position } }
		_spawn_scene(Vector2(x, map_bounds.end.y - margin), behavior)
		x += margin_x

	timeout_timer.start()


func _spawn_circle():
	call_deferred('set_physics_process', true)
	behaviour_container.add('seek', { target = Global.player })

	var behaviour = { id =  "shadow_chase_target", data = { target = self } }
	_spawn_radius(1, 0, behaviour)

	var radius_inc = 20
	if 'spawn_options' in data && data.spawn_options && 'radius' in data.spawn_options:
		radius_inc = data.spawn_options.radius
	
	var size = data.spawn_size
	var radius = radius_inc
	var length = clamp(size - 1, 0,  6)
	var current_length = 1


	while length > 0 && current_length < size:
		_spawn_radius(length, radius, behaviour)
		current_length += length
		length = clamp(length * 2, 0, size - current_length)
		radius += radius_inc
		
	timeout_timer.start()


func _spawn_scene(position: Vector2, behaviour):
	var scene = Global.spawn_id_scene[data.spawn_id]
	var node = scene.instance()
	node.global_position = position
	node.data = FP.patch_dictionary(
		spawn_data,
		{ 
			id = data.spawn_id, 
			collision_layer = null,
			collision_mask = null,
			behaviours = [behaviour, "melee_attack"] 
		}
	)

	# @TODO find a better way
	if Global.map.event_system:
		Global.map.event_system._set_enemy_level_inc(node)

	node.add_to_group('mob_child')
	Global.add_entity(node)
	spawn_nodes.append(node)
	if !spawn_effect_connected:
		spawn_effect_connected = true
		node.get_node('spawn_effect').connect("finished", self, "_on_spawn_effect_finished")

	
func _spawn_radius(length: int, radius: int, behaviour):
	var radius_vec = Vector2(radius, 0).rotated(deg2rad(randi() % 360))
	var step = 2 * PI / length
	for index in length:
		var spawn_pos = global_position + radius_vec.rotated(step * index)
		_spawn_scene(spawn_pos, behaviour)


func _on_spawn_effect_finished():
	state = STATES.IDLE
	
	if collide_with_abysm:
		for index in spawn_nodes.size():
			if is_instance_valid(spawn_nodes[index]):
				spawn_nodes[index].remove_from_group('flyers')
				spawn_nodes[index].behaviour_container.get('move_to_position').connect('moved', self, "_on_spawn_moved", [spawn_nodes[index]])


func _on_spawn_moved(node):
	Global.add_enemy_dead_effect(node.global_position, node.base_color)
	node.queue_free()
	_on_timeout_timer_timeout()


func _on_timeout_timer_timeout():
	for index in spawn_nodes.size():
		if is_instance_valid(spawn_nodes[index]):
			return
	queue_free()


func _on_spawn_duration_timeout():
	for index in spawn_nodes.size():
		var node = spawn_nodes[index]
		if is_instance_valid(node):
			Global.add_enemy_dead_effect(node.global_position, node.base_color)
			node.queue_free()
	queue_free()

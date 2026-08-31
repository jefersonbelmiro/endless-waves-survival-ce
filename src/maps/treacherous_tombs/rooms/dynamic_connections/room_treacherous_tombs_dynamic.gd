extends RoomTreacherousTombsBase

const door_scene = preload("res://src/maps/treacherous_tombs/door/door.tscn")

var data: Dictionary
var links = {}

var wall_tiles = {
	top_right_bottom = 39,
	top_left_bottom = 42,
	top_top_right = 31,
	top_top_left = 28,
	bottom_right_bottom = 43,
	bottom_top = 44,
	bottom_left_bottom = 45,
	bottom_top_right = 46,
	bottom_bottom = 47,
	bottom_top_left = 48,

	left_right = [25, 26, 27, 32, 33, 34],

	top = [40, 41],
	bottom = [29, 30],

	left = [32, 33, 34,],
	right = [25, 26, 27],

	empty_with_collision = 60,
}

var ground_tiles = {
	empty = 49,
	wall = 50,
	cracks = [61, 62, 63, 64, 65, 66, 67, 68, 69, 70],
}

onready var open_sfx = $open_sfx
onready var walls: TileMap = $tile_walls
onready var wall_floor: TileMap = $tile_wall_floor

func _ready():
	bg.color = Color("#1f2438")
	VisualServer.set_default_clear_color(Color('#242424'))
	_create(data.size, data.doors)


func open_gates():
	open_sfx.play()
	for index in doors.size():
		var door = doors[index]
		if door.gateway:
			continue

		door.open()

		var tile_position = walls.world_to_map(door.position)
		_remove_door_collision(door.id, tile_position)
	

func _create(size: Vector2, door_position: Array):
	bg.rect_position = Vector2(8, 6)
	bg.rect_size = size * 16 + Vector2(2, 6)

	# top
	walls.set_cellv(Vector2(0, 0), wall_tiles.top_right_bottom)
	# right
	walls.set_cellv(Vector2(size.x, 0), wall_tiles.top_left_bottom)
	# bottom
	walls.set_cellv(Vector2(size.x, size.y), wall_tiles.top_top_left)
	# left
	walls.set_cellv(Vector2(0, size.y), wall_tiles.top_top_right)

	for x in size.x:
		for y in size.y:
			if randf() > 0.08:
				continue
			var position = Vector2(x, y)
			ground.set_cellv(position, ground_tiles.cracks[randi() % ground_tiles.size()])


	for index in door_position.size():
		var door = door_position[index]
		var door_node = _create_door(door.id, door.position)
		door_node.hide()
		if door.id == data.gateway_id:
			gateway = door_node
			door_node.gateway = true

	for x in size.x - 1:
		var top_position = Vector2(x + 1, 0)
		var bottom_position = top_position + Vector2(0, size.y)
		var top_idx = wall_tiles.top[randi() % wall_tiles.top.size()]
		var bottom_idx = wall_tiles.bottom[randi() % wall_tiles.bottom.size()] 
		walls.set_cellv(top_position, top_idx)
		walls.set_cellv(bottom_position, bottom_idx)

		bounds.set_cellv(top_position + Vector2.DOWN, ground_tiles.empty)
		bounds.set_cellv(bottom_position, ground_tiles.empty)

	for y in size.y - 2:
		var left_position = Vector2(0, y + 2)
		var right_position = left_position + Vector2(size.x, 0)
		var left_idx = wall_tiles.left[randi() % wall_tiles.left.size()]
		var right_idx = wall_tiles.right[randi() % wall_tiles.right.size()] 
		walls.set_cellv(left_position, left_idx)
		walls.set_cellv(right_position, right_idx)

		bounds.set_cellv(left_position, ground_tiles.empty)
		bounds.set_cellv(right_position, ground_tiles.empty)


func remove_door_wall(door: Node2D):
	var position = walls.world_to_map(door.position)
	door.show()
	_remove_door_wall(door.id, position)
	_create_door_tiles(door.id, position)


func close_door_with_wall(door: Node2D):
	var tile_position = walls.world_to_map(door.position)
	door.disabled()
	_close_door_with_wall(door.id, tile_position)


func show_door(door: Node2D):
	var tile_position = walls.world_to_map(door.position)
	door.show()
	_remove_door_wall(door.id, tile_position)
	_create_door_tiles(door.id, tile_position)


func show_door_tunel(door: Node2D):
	var tile_position = walls.world_to_map(door.position)
	_remove_door_wall(door.id, tile_position)
	_create_door_tiles(door.id, tile_position)


func _create_door(id: String, position: Vector2):
	var node = door_scene.instance()
	node.id = id
	node.global_position = walls.map_to_world(position)
	node.connect("body_entered", self, "_on_door_body_entered", [node])
	add_child(node)
	doors.append(node)
	return node
	

func _on_door_body_entered(door):
	call_deferred("emit_signal", "door_entered", door, self)


func _create_door_tiles(door_id: String, position: Vector2):
	match door_id:      
		'top':
			_create_door_top_tiles(position)
		'right':
			_create_door_right_tiles(position)
		'bottom':
			_create_door_bottom_tiles(position)
		'left':
			_create_door_left_tiles(position)


func _fill_top_tunel_ground(position: Vector2, tile_id: int):
	ground.set_cellv(position + Vector2(1, 0), tile_id)
	ground.set_cellv(position + Vector2(2, 0), tile_id)
	ground.set_cellv(position + Vector2(1, -1), tile_id)
	ground.set_cellv(position + Vector2(1, -2), tile_id)
	ground.set_cellv(position + Vector2(1, -3), tile_id)
	ground.set_cellv(position + Vector2(2, -1), tile_id)
	ground.set_cellv(position + Vector2(2, -2), tile_id)
	ground.set_cellv(position + Vector2(2, -3), tile_id)


func _fill_right_tunel_ground(position: Vector2, tile_id: int):
	ground.set_cellv(position + Vector2(0, 1), tile_id)
	ground.set_cellv(position + Vector2(0, 2), tile_id)
	ground.set_cellv(position + Vector2(1, 2), tile_id)
	ground.set_cellv(position + Vector2(2, 2), tile_id)
	ground.set_cellv(position + Vector2(3, 2), tile_id)


func _create_door_top_tiles(position: Vector2):
	walls.set_cellv(position, wall_tiles.bottom_top_left)
	walls.set_cellv(position + Vector2(0, -1), wall_tiles.left[randi() % wall_tiles.left.size()])
	# walls.set_cellv(position + Vector2(0, -2), wall_tiles.left[randi() % wall_tiles.left.size()])
	walls.set_cellv(position + Vector2(3, 0), wall_tiles.bottom_top_right)
	walls.set_cellv(position + Vector2(3, -1), wall_tiles.right[randi() % wall_tiles.right.size()])
	# walls.set_cellv(position + Vector2(3, -2), wall_tiles.right[randi() % wall_tiles.right.size()])

	# door collision
	walls.set_cellv(position + Vector2(1, 0), wall_tiles.empty_with_collision)
	walls.set_cellv(position + Vector2(2, 0), wall_tiles.empty_with_collision)

	_fill_top_tunel_ground(position, ground_tiles.empty)
	

func _create_door_right_tiles(position: Vector2):
	walls.set_cellv(position, wall_tiles.bottom_top_right)
	walls.set_cellv(position + Vector2(1, 0), wall_tiles.bottom_bottom)
	# walls.set_cellv(position + Vector2(2, 0), wall_tiles.bottom_bottom)
	walls.set_cellv(position + Vector2(0, 3), wall_tiles.bottom_right_bottom)
	walls.set_cellv(position + Vector2(1, 3), wall_tiles.bottom_top)
	# walls.set_cellv(position + Vector2(2, 3), wall_tiles.bottom_top)

	# door collision
	walls.set_cellv(position + Vector2(0, 1), wall_tiles.empty_with_collision)
	walls.set_cellv(position + Vector2(0, 2), wall_tiles.empty_with_collision)

	_fill_right_tunel_ground(position, ground_tiles.empty)


func _create_door_bottom_tiles(position: Vector2):
	walls.set_cellv(position, wall_tiles.bottom_left_bottom)
	walls.set_cellv(position + Vector2(0, 1), wall_tiles.left[randi() % wall_tiles.left.size()] )
	# walls.set_cellv(position + Vector2(0, 2), wall_tiles.left[randi() % wall_tiles.left.size()] )
	walls.set_cellv(position + Vector2(3, 0), wall_tiles.bottom_right_bottom)
	walls.set_cellv(position + Vector2(3, 1), wall_tiles.right[randi() % wall_tiles.right.size()] )
	# walls.set_cellv(position + Vector2(3, 2), wall_tiles.right[randi() % wall_tiles.right.size()] )

	# door collision
	walls.set_cellv(position + Vector2(1, 0), wall_tiles.empty_with_collision)
	walls.set_cellv(position + Vector2(2, 0), wall_tiles.empty_with_collision)


func _create_door_left_tiles(position: Vector2):
	walls.set_cellv(position, wall_tiles.bottom_top_left)
	walls.set_cellv(position + Vector2(-1, 0), wall_tiles.bottom_bottom)
	# walls.set_cellv(position + Vector2(-2, 0), wall_tiles.bottom_bottom)
	walls.set_cellv(position + Vector2(0, 3), wall_tiles.bottom_left_bottom)
	walls.set_cellv(position + Vector2(-1, 3), wall_tiles.bottom_top)
	# walls.set_cellv(position + Vector2(-2, 3), wall_tiles.bottom_top)

	# door collision
	walls.set_cellv(position + Vector2(0, 1), wall_tiles.empty_with_collision)
	walls.set_cellv(position + Vector2(0, 2), wall_tiles.empty_with_collision)


func _close_door_with_wall(door_id: String, position: Vector2):
	_remove_door_tunnel(door_id, position)
	match door_id:      
		'top':
			for tile_index in 4: 
				walls.set_cellv(position + Vector2(tile_index * 1, 0), wall_tiles.top[randi() % wall_tiles.top.size()])
			_fill_top_tunel_ground(position, -1)
		'right':
			for tile_index in 4: 
				walls.set_cellv(position + Vector2(0, tile_index * 1), wall_tiles.right[randi() % wall_tiles.right.size()])
			_fill_right_tunel_ground(position, -1)
		'bottom':
			for tile_index in 4: 
				walls.set_cellv(position + Vector2(tile_index * 1, 0), wall_tiles.bottom[randi() % wall_tiles.bottom.size()])
		'left':
			for tile_index in 4: 
				walls.set_cellv(position + Vector2(0, tile_index * 1), wall_tiles.left[randi() % wall_tiles.left.size()])


func _remove_door_wall(door_id: String, position: Vector2):
	match door_id:
		'top':
			for tile_index in 4: 
				walls.set_cellv(position + Vector2(tile_index * 1, 0), -1)
		'right':
			for tile_index in 4: 
				walls.set_cellv(position + Vector2(0, tile_index * 1), -1)
		'bottom':
			for tile_index in 4: 
				walls.set_cellv(position + Vector2(tile_index * 1, 0), -1)
		'left':
			for tile_index in 4: 
				walls.set_cellv(position + Vector2(0, tile_index * 1), -1)


func _remove_door_tunnel(door_id: String, position: Vector2):
	match door_id:
		'top':
			walls.set_cellv(position + Vector2(0, -1), -1)
			walls.set_cellv(position + Vector2(0, -2), -1)
			walls.set_cellv(position + Vector2(3, -1), -1)
			walls.set_cellv(position + Vector2(3, -2), -1)
		'right':
			walls.set_cellv(position + Vector2(1, 0), -1)
			walls.set_cellv(position + Vector2(2, 0), -1)
			walls.set_cellv(position + Vector2(1, 3), -1)
			walls.set_cellv(position + Vector2(2, 3), -1)
		'bottom':
			walls.set_cellv(position + Vector2(0, 1), -1)
			walls.set_cellv(position + Vector2(0, 2), -1)
			walls.set_cellv(position + Vector2(3, 1), -1)
			walls.set_cellv(position + Vector2(3, 2), -1)
		'left':
			walls.set_cellv(position + Vector2(-1, 0), -1)
			walls.set_cellv(position + Vector2(-2, 0), -1)
			walls.set_cellv(position + Vector2(-1, 3), -1)
			walls.set_cellv(position + Vector2(-2, 3), -1)


func _remove_door_collision(door_id: String, position: Vector2):
	match door_id:
		'top':
			walls.set_cellv(position + Vector2(1, 0), -1)
			walls.set_cellv(position + Vector2(2, 0), -1)
		'right':
			walls.set_cellv(position + Vector2(0, 1), -1)
			walls.set_cellv(position + Vector2(0, 2), -1)
		'bottom':
			walls.set_cellv(position + Vector2(1, 0), -1)
			walls.set_cellv(position + Vector2(2, 0), -1)
		'left':
			walls.set_cellv(position + Vector2(0, 1), -1)
			walls.set_cellv(position + Vector2(0, 2), -1)



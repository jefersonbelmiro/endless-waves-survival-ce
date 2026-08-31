extends RoomTreacherousTombsBase

const door_scene = preload("res://src/maps/treacherous_tombs/door/door.tscn")

var data: Dictionary

var wall_tiles = {
	top_right_bottom = 39,
	top_left_bottom = 42,
	top_top_right = 31,
	top_top_left = 28,

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
	_create()


func open_gates():
	open_sfx.play()
	for index in doors.size():
		var door = doors[index]
		if door.gateway:
			continue
		door.open()
	

func _create():
	var size = data.size
	var door_position = data.doors
	size += Vector2(1, 1)

	bg.rect_position = Vector2(8, 6)
	bg.rect_size = size * 16 + Vector2(2, 6)

	# top
	walls.set_cellv(Vector2(0, 0), wall_tiles.top_right_bottom)
	# for x in range(0, size.x + 1):
	# 	walls.set_cellv(Vector2(x, -1), wall_tiles.empty_with_collision)
	# 	walls.set_cellv(Vector2(x, -2), wall_tiles.empty_with_collision)

	# right
	walls.set_cellv(Vector2(size.x, 0), wall_tiles.top_left_bottom)
	# for y in range(-2, size.y + 3):
	# 	walls.set_cellv(Vector2(size.x + 1, y), wall_tiles.empty_with_collision)
	# 	walls.set_cellv(Vector2(size.x + 2, y), wall_tiles.empty_with_collision)

	# bottom
	walls.set_cellv(Vector2(size.x, size.y), wall_tiles.top_top_left)
	# for x in range(0, size.x + 1):
	# 	walls.set_cellv(Vector2(x, size.y + 1), wall_tiles.empty_with_collision)
	# 	walls.set_cellv(Vector2(x, size.y + 2), wall_tiles.empty_with_collision)

	# left
	walls.set_cellv(Vector2(0, size.y), wall_tiles.top_top_right)
	# for y in range(-2, size.y + 3):
	# 	walls.set_cellv(Vector2(-1, y), wall_tiles.empty_with_collision)
	# 	walls.set_cellv(Vector2(-2, y), wall_tiles.empty_with_collision)

	# ground cracks
	for x in size.x:
		for y in size.y:
			if randf() > 0.08:
				continue
			var position = Vector2(x, y)
			ground.set_cellv(position, ground_tiles.cracks[randi() % ground_tiles.cracks.size()])


	var door_position_data = {}
	for index in door_position.size():
		var door = door_position[index]
		var position = door.position + Vector2(1, 0)
		var door_node = _create_door(door.id, position)
		if data.id == 'chest':
			door_node.open()
		if door.id == 'gateway':
			gateway = door_node
		for position_index in 4:
			door_position_data[position + Vector2(position_index * 1, 0)] = true

	for x in size.x - 1:
		var top_position = Vector2(x + 1, 0)
		var bottom_position = top_position + Vector2(0, size.y)
		var top_idx = wall_tiles.top[randi() % wall_tiles.top.size()]
		var bottom_idx = wall_tiles.bottom[randi() % wall_tiles.bottom.size()] 
		if !(top_position in door_position_data):
			walls.set_cellv(top_position, top_idx)
		else:
			walls.set_cellv(top_position, wall_tiles.empty_with_collision)
		walls.set_cellv(bottom_position, bottom_idx)

		bounds.set_cellv(top_position, ground_tiles.empty)
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



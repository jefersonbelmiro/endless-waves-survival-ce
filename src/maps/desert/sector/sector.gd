extends Node2D

const ground_tiles = {
	cracks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
}

var size: Vector2
var links = {
	top = null, # north
	top_right = null, # northeast
	right = null, # east
	bottom_right = null, # southeast
	bottom = null, # south
	bottom_left = null, # southwest
	left = null, # west
	top_left = null, # northwest
}

var rect: Rect2

onready var ground = $tile_ground


func _ready():
	_create()


func get_center_position():
	return global_position + rect.get_center()


func _create():
	var tile_size = size / ground.cell_size + Vector2(-1, -1)
	for x in tile_size.x:
		for y in tile_size.y:
			if randf() > 0.08:
				continue
			var position = Vector2(x, y) 
			if ground.get_cellv(position) == ground.INVALID_CELL:
				ground.set_cellv(position, ground_tiles.cracks[randi() % ground_tiles.cracks.size()])





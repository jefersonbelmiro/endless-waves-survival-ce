extends Area2D

var half_width
var half_heigth
var bounds
var limit_left
var limit_right
var limit_top
var limit_bottom
var parent

var size

onready var collision_shape = $collision_shape_2d.shape

func _ready():
	parent = get_parent()
	_set_size()
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	

func _process(_delta):
	global_position = parent.global_position 
	
	if global_position.x >= limit_right:
		global_position.x = limit_right
	elif global_position.x <= limit_left:
		global_position.x = limit_left

	if global_position.y >= limit_bottom:
		global_position.y = limit_bottom
	elif global_position.y <= limit_top:
		global_position.y = limit_top


func _set_size():
	size = get_viewport_rect().size * 0.5
	collision_shape.extents = size - Vector2(5, 5)
	
	var margin = Vector2(30, 30)
	half_width = size.x
	half_heigth = size.y
	bounds = Global.map.get_spawn_bounds()
	limit_left = bounds.position.x  + half_width - margin.x
	limit_right = bounds.end.x - half_width + margin.x
	limit_top = bounds.position.y + half_heigth - margin.y
	limit_bottom = bounds.end.y - half_heigth + margin.y


func _on_size_changed():
	_set_size()

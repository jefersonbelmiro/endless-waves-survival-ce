extends Line2D

export var max_length = 20

onready var parent = get_parent()


func _process(_delta):
	global_rotation = 0
	global_position = Vector2.ZERO
	global_scale = Vector2(1, 1)
	add_point(parent.global_position)
	
	while points.size() > max_length:
		remove_point(0)

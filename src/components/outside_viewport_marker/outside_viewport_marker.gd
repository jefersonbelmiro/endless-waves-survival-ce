extends Node

var marker_size = Vector2(8, 8)

onready var parent = get_parent()
onready var container = $container
onready var pointer = $container/pointer
onready var texture = $container/texture

func _process(_delta):
	var viewport = Global.get_viewport_bounds()

	container.visible = !viewport.has_point(parent.global_position)
	if !container.visible:
		return

	var bounds = viewport.grow_individual(-8, -30, -8, -30)
	var position = parent.global_position

	var direction = (parent.global_position - Global.player.global_position).normalized()
	texture.position = direction * -8
	pointer.rotation = (parent.global_position - Global.player.global_position).angle()
	container.global_position.x = clamp(position.x, bounds.position.x, bounds.end.x - marker_size.x)
	container.global_position.y = clamp(position.y, bounds.position.y + marker_size.y, bounds.end.y - marker_size.y)


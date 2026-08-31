extends Node2D

onready var collision = $collision_shape_2d
onready var collision_shape: CircleShape2D = $collision_shape_2d.shape

var data
var ignore = []
var frames_free: int = 1

func _ready():
	collision_shape.radius = data.area * 0.5
	# @FIXME this works? performance issue?
#	collision.scale = Vector2(1, 0.7)


func _physics_process(_delta):
	if frames_free <= 0:
		queue_free()
	frames_free -= 1


func _on_explosion_hitbox_area_entered(area_obj):
	if ignore.has(area_obj.parent):
		return
	data.target_node = area_obj.get_parent()
	data.position = global_position
	var hit_data = data.duplicate(true)
	if is_instance_valid(data.source_node) && 'stats' in data.source_node:
		hit_data = data.source_node.stats.hit(hit_data) 
	area_obj.hitted(hit_data)
	queue_free()

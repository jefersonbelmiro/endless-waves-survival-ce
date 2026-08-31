extends Node2D

var target: Node2D
var target_position: Vector2
var start_position: Vector2
var high_position: Vector2
var duration = 1.0
var elapsed = 0.0

onready var particles = $particles_2d
onready var sprite = $sprite
onready var trail_particles = $trail_particles

func _ready():
	start_position = global_position
	high_position = start_position + Vector2(0, -150)


func _process(delta):
	if is_instance_valid(target):
		target_position = target.global_position

	if elapsed > duration:
		queue_free()
		return

	elapsed += delta
	var weight = elapsed / duration
	global_position = _get_position(start_position, high_position, target_position, weight)


# use quadratic bezier
# https://docs.godotengine.org/en/3.6/tutorials/math/beziers_and_curves.html
func _get_position(start, high, end, weight: float):
	var q0 = start.linear_interpolate(high, weight)
	var q1 = high.linear_interpolate(end, weight)
	return q0.linear_interpolate(q1, weight)


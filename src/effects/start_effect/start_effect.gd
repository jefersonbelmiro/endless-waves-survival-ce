extends Node2D

signal finished

export var color = Color.white

var margin_y = 8
var color_shift = 0

onready var outside_particles = $outside_particles
onready var inner_particles = $inner_particles

func _ready():
	modulate = color
	global_position += Vector2(0, margin_y)
	outside_particles.emitting = true
	inner_particles.emitting = true
	

func _on_stop_timer_timeout():
	outside_particles.emitting = false
	inner_particles.emitting = false
	get_tree().create_timer(0.5, false).connect('timeout', self, "_finished")


func _finished():
	emit_signal('finished')
	queue_free()

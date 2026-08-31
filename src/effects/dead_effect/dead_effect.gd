extends Node2D

export var color = Color('#ffffff')
export var amount = 200
export var lifetime = 0.5

onready var particles = $particles_2d

func _ready():
	particles.one_shot = true
	particles.emitting = true
	particles.process_material.color = color
	particles.amount = amount
	particles.lifetime = lifetime


func _on_timeout_timer_timeout():
	queue_free()


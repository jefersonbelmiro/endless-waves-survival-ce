extends Node2D
onready var particles = $particles_2d

func _ready():
	particles.emitting = true
	particles.one_shot = true
	Global.delay_func(self, "queue_free", 10.5)


func _stop():
	particles.emitting = false
	Global.delay_func(self, "queue_free", 0.1)

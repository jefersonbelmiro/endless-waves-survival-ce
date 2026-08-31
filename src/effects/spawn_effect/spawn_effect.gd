extends Node2D

signal finished()

onready var sprite = $animated_sprite

func _ready():
	sprite.play()
	

func _on_animated_sprite_animation_finished():
	emit_signal("finished")
	queue_free()

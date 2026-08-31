extends Node2D

onready var sprite = $animated_sprite


func _ready():
	sprite.play()
	

func _on_animated_sprite_animation_finished():
	queue_free()

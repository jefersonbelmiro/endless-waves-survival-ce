extends Node2D

signal body_entered()

export var id = 'gateway'
export var openned = false
export var gateway = false

onready var area_collision = $area_2d/collision_shape_2d
onready var sprite = $animated_sprite


func open():
	openned = true
	sprite.play("gatway_oppening")
	get_tree().create_timer(0.7).connect("timeout", area_collision, 'set_deferred', ['disabled', false])


func _on_area_2d_body_entered(body):
	if body.is_alive():
		emit_signal("body_entered")

extends Node2D

export var area: float = 10
export var color = Color('#ffffff')
export var speed_scale = 1

onready var sprite = $animated_sprite
onready var glow = $glow

var initial_area: float = 10
var initial_factor: float = 0.1


func _ready():
	var scale = FP.calculate_scale_from_area(area, initial_area, initial_factor)
	sprite.scale = scale + Vector2(0, -scale.y * 0.4)
	sprite.modulate = color - Color(0,0, 0, 0.8)
	sprite.modulate.a = color.a * 0.2
	sprite.speed_scale = speed_scale
	sprite.play()
	
	if Settings.get_glow_effect():
		glow.modulate = color
#		glow.modulate = color + Color(1.5, 1.5, 1.5)
#		glow.modulate.a = 1.0
#		glow.scale = FP.calculate_scale_from_area(area, 20, 0.7)
		glow.show()


func _on_animated_sprite_animation_finished():
	queue_free()

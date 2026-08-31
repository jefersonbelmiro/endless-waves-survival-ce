extends Node2D

var color = Color('#ffffff')
var velocity = Vector2(0, 20)
var text: String
var bg_texture

onready var bg = $bg
onready var label = $label
onready var tween = $tween

func _ready():
	randomize()
	
	if bg_texture:
		bg.texture = bg_texture
		bg.show()

	# global_position += Vector2(rand_range(-10, 10), rand_range(-10, 10))
	
	label.set_text(str(text))
	label.set("custom_colors/font_color", color)

	var initial_scale = scale - Vector2(0.3, 0.3)
	var final_scale = scale
	
	tween.interpolate_property(self, 'scale', initial_scale, final_scale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', final_scale, initial_scale, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()

func _process(delta):
	position -= velocity * delta


func _on_tween_tween_all_completed():
	queue_free()

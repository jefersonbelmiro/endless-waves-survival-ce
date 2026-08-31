extends Node2D

onready var tween = $tween
onready var label = $label

func _ready():
	var duration = 0.370
	var delay = 0.5
	modulate.a = 0
	tween.interpolate_property(self, 'modulate:a', 0.5, 1, duration, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, delay)
	tween.interpolate_property(self, 'position', Vector2(0, -18), Vector2(0, -30), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	tween.interpolate_property(self, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay + duration)
	tween.start()


func _on_tween_tween_all_completed():
	queue_free()

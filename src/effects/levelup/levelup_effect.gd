extends NinePatchRect

onready var sfx = $levelup_sfx

func _ready():
	var duration = 0.370
	var final_scale = rect_scale
	rect_scale = Vector2(0, 1)
	modulate.a = 0

	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween.tween_property(self, 'rect_scale', final_scale, duration)
	tween.tween_property(self, 'modulate:a', 0.7, duration)
	tween.connect("finished", self, "queue_free")

	sfx.play()


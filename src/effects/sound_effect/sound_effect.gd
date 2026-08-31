extends AudioStreamPlayer


func _on_sound_effect_finished():
	queue_free()

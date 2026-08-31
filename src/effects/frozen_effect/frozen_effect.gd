extends Sprite

func _ready():
	var parent = get_parent()
	if parent.is_in_group("mini_bosses"):
		scale = Vector2(0.8, 0.8)
		position = Vector2(0, -4)
	elif parent.is_in_group("bosses"):
		scale = Vector2(1.2, 1.2)
		position = Vector2(0, -4)

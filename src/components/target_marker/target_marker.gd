extends Sprite

export var area: float setget set_area

var initial_area: float = 10
var initial_factor: float = 0.1

func _ready():
	set_as_toplevel(true)
	if area:
		_show()


func set_area(value):
	area = value
	if !visible && is_inside_tree():
		_show()


func _show():
	show()
	var area_scale = FP.calculate_scale_from_area(area, initial_area, initial_factor)
	var final_scale = area_scale + Vector2(0, -area_scale.y * 0.4)
	scale = Vector2(0, 0)
	
#	scale = Vector2(0.2, 0.2)
#	var final_scale = FP.calculate_scale_from_area(area, 16, 1)

	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT )
	tween.tween_property(self, 'scale', final_scale, 0.50)


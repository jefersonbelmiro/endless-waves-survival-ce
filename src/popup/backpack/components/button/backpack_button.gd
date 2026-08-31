extends BoxButton

export var size: int = 0 setget _set_size_value

onready var size_label = $size_label

func _ready():
	_set_size_value(size)
	set_font_size(font_size)


func set_font_size(value):
	.set_font_size(value)
	if size_label:
		size_label.set('custom_fonts/font', Global.get_font(font_size, 1))


func _set_size_value(value: int):
	size = value
	if size_label:
		if size > 0:
			size_label.text = str(size)
			size_label.show()
		else:
			size_label.hide()
		

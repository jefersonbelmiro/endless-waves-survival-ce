extends NinePatchRect

export var icon_texture: Texture
export var label_value: int setget set_label_value
export var font_size = 16 setget set_font_size

onready var cooldown_node = $cooldown
onready var label = $label
onready var texture_rect = $texture_rect

func _ready():
	texture_rect.texture = icon_texture
	if label_value:
		label.show()
		label.text = str(label_value)
		label.set('custom_fonts/font', Global.get_font(font_size, 1))
	
	
func set_label_value(value):
	if value != null:
		label_value = value
	if label:
		label.text = str(label_value)
		label.show()
		

func set_font_size(value):
	font_size = value
	if label:
		label.set('custom_fonts/font', Global.get_font(font_size, 1))


func set_progress(value: float, max_value: float):
	if !cooldown_node:
		return
	cooldown_node.value = value
	cooldown_node.max_value = max_value

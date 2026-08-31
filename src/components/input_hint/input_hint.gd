extends Control

export(int, FLAGS, "Keyboard", "Touch", "Joypad") var sources = 0
export var label: String
export var label_color = Color('#acaaaa')
export var label_font_size = 8

onready var label_node = $container/label

func _ready():
	_on_input_source_changed(InputSource.source)
	InputSource.connect("input_source_changed", self, "_on_input_source_changed")

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")


func _on_input_source_changed(source):
	if source == InputSource.KEYBOARD:
		visible = has_keyboard()
	elif source == InputSource.TOUCH:
		visible = has_touch()
	elif source == InputSource.JOYPAD:
		visible = has_joypad()
	
	
func has_keyboard():
	return FP.is_bit_enabled(sources, 0)
	
	
func has_touch():
	return FP.is_bit_enabled(sources, 1)


func has_joypad():
	return FP.is_bit_enabled(sources, 2)


func _on_language_changed():
	if label:
		label_node.text = label
		label_node.set('custom_colors/font_color', label_color)
		label_node.set('custom_fonts/font', Global.get_font(label_font_size))


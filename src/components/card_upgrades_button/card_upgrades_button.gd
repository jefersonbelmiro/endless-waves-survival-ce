extends Control

export var size: Vector2
export var font_size = 8
export var label_color = Color('#acaaaa')
export var text_label = "" setget set_text_label

var _padding_bottom = Vector2(0, 6)

onready var button = $container/button
onready var label = $container/label

func _ready():
	_padding_bottom.y = floor(label.get_font("font").get_string_size(label.text).y)
	if size:
		rect_min_size = size + _padding_bottom
		rect_size = rect_min_size
		button.rect_min_size = size

	label.text = text_label 

	label.text = tr(text_label)
	label.set('custom_colors/font_color', label_color)
	label.set('custom_fonts/font', Global.get_font(font_size))

	Settings.connect("language_changed", self, "_on_language_changed")

func _draw():
	label.modulate = button.label.modulate


func set_text_label(value: String):
	text_label = value
	if label:
		label.text = text_label


func update():
	button.update()
	.update()
	

func _on_language_changed():
	# update translation
	label.text = text_label
	label.set('custom_fonts/font', Global.get_font(font_size))

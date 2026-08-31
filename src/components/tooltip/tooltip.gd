extends Control

export var text: String setget set_text

onready var label = $label
onready var arrow = $arrow

var _mouse_hover = false

func _ready():
	set_as_toplevel(true)
	hide()
	
	label.bbcode_text = text
	get_parent().connect("focus_entered", self, "_on_focus_entered")
	get_parent().connect("focus_exited", self, "_on_focus_exited")
	get_parent().connect("mouse_entered", self, "_on_mouse_entered")
	get_parent().connect("mouse_exited", self, "_on_mouse_exited")
	get_parent().connect("hide", self, "_on_hide")

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")


func set_text(value):
	text = value
	if label:
		label.bbcode_text = text
		_update()


func _on_focus_entered():
	_update()


func _on_focus_exited():
	_update()


func _on_mouse_entered():
	_mouse_hover = true
	_update()


func _on_mouse_exited():
	_mouse_hover = false
	_update()


func _on_hide():
	_mouse_hover = false
	_update()


func _update():
	if !_visible():
		return hide()
	show()
	var label_font = label.get_font("normal_font")
	var font_size = label_font.get_string_size(_strip_bbcode(text))
	
	font_size.y = max(font_size.y, 6.5)
	rect_min_size = font_size + Vector2(4, 4)
	rect_size = font_size + Vector2(4, 4)

	rect_global_position = get_parent().rect_global_position + Vector2(-(rect_size.x/2), -(rect_size.y + 4)) + Vector2(get_parent().rect_size.x/2, 0)
	arrow.rect_position = Vector2(rect_size.x/2 - 6, 6)


func _visible():
	if !is_inside_tree():
		return false
	return text && (get_focus_owner() == get_parent() || _mouse_hover)


func _strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\].*\\[.+?\\]")
	return regex.sub(source, "**", true)


func _on_language_changed():
	label.set('custom_fonts/normal_font', Global.get_font(8))


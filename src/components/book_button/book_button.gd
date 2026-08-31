extends Button
tool

export var icon_texture: Texture setget set_icon_texture
export var text_label: String setget set_text_label
export var bg_texture: Texture setget set_bg_texture
export var label_color = Color('#acaaaa')
export var bg_color = Color('#6b3e75') setget set_bg_color

# @FIXME use insted of shift color factors
export var selected_color = Color('#131313')
export var pressed_color = Color('#131313')

export var sync_size_with_label = false

export var hover_shift_color = 0.05
export var selected_shift_color = 0.05
export var pressed_shift_color = 0.05

onready var label = $label
onready var label_font = label.get_font("font")

var mouse_hover = false
var pressing = false
var initial_min_size: Vector2

onready var selected_sizes = {
	size_initial = rect_size,
	position_initial = $selected.rect_position 
}


func _ready():
	$label.text = tr(text_label)
	$label.set('custom_colors/font_color', label_color)
	$selected.modulate = bg_color - Color(selected_shift_color, selected_shift_color, selected_shift_color, 0)
	$bg_pressed.modulate = pressed_color - Color(pressed_shift_color, pressed_shift_color, pressed_shift_color)
	$bg_pressed.modulate.a = 0
	$bg.modulate = bg_color
	
	_create_selected_tween()
	_update_size()
	
	Settings.connect("language_changed", self, "_on_language_changed")
	

func _draw():
	if disabled:
		$label.modulate.a = 0.2
		$fg.modulate.a = 0.3
		$bg.modulate.a = 0.7
	else:
		$label.modulate.a = 1
		$fg.modulate.a = 1
		$bg.modulate.a = 1
	
	if mouse_hover:
		$bg.modulate = bg_color - Color(hover_shift_color, hover_shift_color, hover_shift_color, 0)
	else:
		$bg.modulate = bg_color
		
	if toggle_mode:
		$bg_pressed.modulate.a = 1 if pressed else 0


func set_text_label(text: String):
	text_label = text
	if label:
		label.text = text_label
		_update_size()


func set_icon_texture(texture: Texture):
	icon_texture = texture
	if has_node('fg'):
		$fg.texture =  texture
	
	
func set_bg_texture(texture: Texture):
	bg_texture = texture
	if has_node('bg'):
		$bg.texture = texture
		$bg.modulate = bg_color


func set_bg_color(color: Color):
	bg_color = color
	if has_node("selected"):
		$selected.modulate = bg_color - Color(selected_shift_color, selected_shift_color, selected_shift_color, 0)
	if has_node("bg_pressed"):
		$bg_pressed.modulate = bg_color - Color(pressed_shift_color, pressed_shift_color, pressed_shift_color, 0)
		$bg_pressed.modulate.a = 0
	if has_node('bg'):
		$bg.modulate = bg_color


func _update_size():
	if !sync_size_with_label:
		return
	if !initial_min_size:
		initial_min_size = rect_min_size
	var size = label_font.get_string_size(text_label)
	var width = size.x + 10
	var height = size.y
	rect_min_size = Vector2(max(initial_min_size.x, width), max(initial_min_size.y, height))
	

func _create_selected_tween():
	var duration = 0.3
	var transition = Tween.TRANS_ELASTIC
	var size_initial = selected_sizes.size_initial
	var size_final = size_initial + Vector2(4, 4)
	var position_initial = selected_sizes.position_initial
	var position_final =  position_initial - Vector2(2, 2)
	$selected_tween.interpolate_property($selected, 'rect_size', size_initial, size_final, duration, transition, Tween.EASE_IN_OUT, duration)
	$selected_tween.interpolate_property($selected, 'rect_position', position_initial, position_final, duration, transition, Tween.EASE_IN_OUT, duration)
	$selected_tween.interpolate_property($selected, 'rect_size', size_final, size_initial, duration, transition, Tween.EASE_IN_OUT, duration * 2)
	$selected_tween.interpolate_property($selected, 'rect_position', position_final, position_initial, duration, transition, Tween.EASE_IN_OUT, duration * 2)


func _on_book_button_focus_entered():
	$selected.show()
	$selected_tween.stop_all()
	$selected_tween.start()


func _on_book_button_focus_exited():
	$selected_tween.stop_all()
	$selected.rect_size = selected_sizes.size_initial
	$selected.rect_position = selected_sizes.position_initial
	$selected.hide()


func _on_book_button_button_down():
	if disabled || (toggle_mode && pressed):
		return
		
	pressing = true
	SFX.add_button_pressed()

#	_on_book_button_focus_exited()
	
	$pressed_tween.interpolate_property($bg_pressed, 'modulate:a', 0, 1, 0.09, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$pressed_tween.interpolate_property($bg_pressed, 'rect_scale', Vector2(0.5, 0.5), Vector2(1, 1), 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$pressed_tween.interpolate_property($bg_pressed, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.09, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.15)

#	$bg_pressed.show()
	$pressed_tween.start()


func _on_book_button_button_up():
	if toggle_mode && pressed:
		pressing = false
		return
	if pressing:
		$pressed_tween.interpolate_property($bg_pressed, 'modulate:a', 1, 0, 0.09, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.09)
		$pressed_tween.start()
		pressing = false
		


func _on_book_button_mouse_entered():
	mouse_hover = true


func _on_book_button_mouse_exited():
	mouse_hover = false


func _on_book_button_hide():
	mouse_hover = false


func _on_book_button_resized():
	selected_sizes = {
		size_initial = rect_size,
		position_initial = $selected.rect_position 
	}
	_create_selected_tween()


func _on_language_changed():
	# update translation
	label.text = text_label 

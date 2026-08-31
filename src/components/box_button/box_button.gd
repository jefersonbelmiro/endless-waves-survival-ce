extends Button
class_name BoxButton

export var icon_texture: Texture setget set_icon_texture 
export var icon_color: Color
export var text_label: String setget set_text_label 
export var label_color = Color('#acaaaa')
export var bg_texture: Texture setget set_bg_texture
export var bg_color = Color('#251625') 
export var border_color = Color('#2b6b3e75') 
export var border_texture: Texture
export var selected_color = Color('#6b3e75') 
export var pressed_color = Color('#6b3e75') 
export var hover_color = Color('#170e17') 
export var pressed_alpha = 0.7
export var font_size = 8 setget set_font_size

export var soft_disabled: bool

var pressing = false
var mouse_hover = false
var selected_tween
var pressed_tween

onready var label = $label
onready var bg = $bg
onready var fg = $fg
onready var bg_pressed = $bg_pressed
onready var selected = $selected
onready var bg_color_node = $bg_color
onready var border_node = $border


func _ready():
	if text_label:
		label.show()
		label.text = tr(text_label)
		label.set('custom_colors/font_color', label_color)
		label.set('custom_fonts/font', Global.get_font(font_size))
	
	if bg_texture:
		bg.texture = bg_texture
		bg.show()
		
	border_node.modulate = border_color
	if border_texture:
		border_node.texture = border_texture
	
	if icon_texture:
		fg.texture = icon_texture
	if icon_color:
		fg.modulate = icon_color
	
	fg.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	fg.margin_left = 2
	fg.margin_top = 2
	fg.margin_right = -2
	fg.margin_bottom = -2
	
	selected.modulate = selected_color
	bg_pressed.modulate = pressed_color
	bg_pressed.modulate.a = 0
	if bg_color:
		bg_color_node.modulate = bg_color
		bg_color_node.show()
	
	Settings.connect("language_changed", self, "_on_language_changed")
	

func _draw():
	if disabled || soft_disabled:
		label.modulate.a = 0.2
		fg.modulate.a = 0.3
		bg.modulate.a = 0.7
	else:
		label.modulate.a = 1
		fg.modulate.a = 1
#		bg.modulate.a = 1
	
	if mouse_hover && bg_color:
		bg_color_node.modulate = hover_color
	elif bg_color:
		bg_color_node.modulate = bg_color
		
	if toggle_mode:
		bg_pressed.modulate.a = pressed_alpha if pressed else 0


func set_icon_texture(texture: Texture):
	icon_texture = texture
	if fg:
		fg.texture =  texture


func set_text_label(text: String):
	text_label = text
	if label:
		label.text = text_label
		
		
func set_bg_texture(value):
	bg_texture = value
	if bg:
		bg.texture = bg_texture


func set_font_size(value):
	font_size = value
	if label:
		label.set('custom_fonts/font', Global.get_font(font_size))


func _on_focus_entered():
	var size_initial = rect_size
	var size_final = size_initial + Vector2(4, 4)
	var position_initial = Vector2(0, 0) 
	var position_final =  position_initial - Vector2(2, 2)
	
	selected.show()
	selected.rect_size  = size_initial
	selected.rect_position = position_initial
	selected_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT).set_loops()
	selected_tween.tween_property(selected, 'rect_size', size_final, 0.3).set_delay(0.5)
	selected_tween.parallel().tween_property(selected, 'rect_position', position_final, 0.3).set_delay(0.5)
	selected_tween.tween_property(selected, 'rect_size', size_initial, 0.3)
	selected_tween.parallel().tween_property(selected, 'rect_position', position_initial, 0.3)
	selected_tween.tween_interval(1)
	

func _on_focus_exited():
	if selected_tween:
		selected_tween.kill()
	selected.hide()
	if pressing:
		bg_pressed.modulate.a = 0
		bg_pressed.rect_scale = Vector2(1, 1)
		if pressed_tween:
			pressed_tween.kill()
		pressing = false


func _on_button_down():
	if disabled || (toggle_mode && pressed):
		return
		
	pressing = true
	SFX.add_button_pressed()
	
	bg_pressed.modulate.a = 0
	bg_pressed.rect_scale = Vector2(0.5, 0.5)
	bg_pressed.rect_pivot_offset = bg_pressed.rect_size/2
	if pressed_tween && pressed_tween.is_running():
		pressed_tween.kill()
	pressed_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	pressed_tween.tween_property(bg_pressed, 'modulate:a', pressed_alpha, 0.25)
	pressed_tween.tween_property(bg_pressed, 'rect_scale', Vector2(1, 1), 0.25)


func _on_button_up():
	if toggle_mode && pressed:
		pressing = false
		return
	if pressing:
		if pressed_tween && pressed_tween.is_running():
			var remain_duration_factor = bg_pressed.modulate.a/pressed_alpha if bg_pressed.modulate.a > 0 else 1
			pressed_tween.kill()
			pressed_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
			pressed_tween.tween_property(bg_pressed, 'modulate:a', pressed_alpha, 0.25 * remain_duration_factor)
			pressed_tween.tween_property(bg_pressed, 'rect_scale', Vector2(1, 1), 0.25 * remain_duration_factor)
			pressed_tween.chain().tween_property(bg_pressed, 'modulate:a', 0.0, 0.25)
		else:
			pressed_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			pressed_tween.tween_property(bg_pressed, 'modulate:a', 0.0, 0.25)
		pressing = false


func _on_mouse_entered():
	mouse_hover = true


func _on_mouse_exited():
	mouse_hover = false


func _on_hide():
	mouse_hover = false


func _on_language_changed():
	# update translation
	label.text = text_label
	label.set('custom_fonts/font', Global.get_font(font_size))


func _on_button_resized():
	if selected && selected_tween && selected_tween.is_running():
		selected_tween.kill()
		selected.set_margins_preset(PRESET_WIDE)
		_on_focus_entered()
		

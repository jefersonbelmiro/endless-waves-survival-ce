extends Control

signal toggled(button_pressed)

export var label_on = "ON"
export var label_off = "OFF"
export var pressed = false setget set_pressed

export var selected_color = Color('#6b3e75') 
export var pressed_color = Color('#6b3e75') 
export var hover_color = Color('#170e17') 
export var pressed_alpha = 0.7
export var font_size = 8

var pressing = false
var selected_tween
var pressed_tween

onready var selected = $selected
onready var bg_pressed = $bg_pressed
onready var button = $button
onready var label = $label
onready var state_bg = $state_bg


func _ready():
	selected.modulate = selected_color
	bg_pressed.modulate = pressed_color
	bg_pressed.modulate.a = 0
	button.pressed = pressed
	_update_label()


func set_pressed(value):
	pressed = value
	if button:
		button.pressed = pressed
	
func _update_label():
	var text = label_on if button.pressed else label_off
	# var font = label.get_font('font')
	# var size = font.get_string_size(text).x
	label.text = text
	if button.pressed:
		label.align = Label.ALIGN_LEFT
		state_bg.set_anchors_and_margins_preset(Control.PRESET_WIDE)
		state_bg.margin_right = -rect_size.x/2.0 + 4
	else:
		label.align = Label.ALIGN_RIGHT
		state_bg.set_anchors_and_margins_preset(Control.PRESET_WIDE)
		state_bg.margin_left =  rect_size.x/2.0 - 4

	

func _on_button_focus_entered():
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
	

func _on_button_focus_exited():
	if selected_tween:
		selected_tween.kill()
	selected.hide()
	if pressing:
		bg_pressed.modulate.a = 0
		if pressed_tween:
			pressed_tween.kill()
		pressing = false


func _on_button_button_down():
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


func _on_button_button_up():
	if pressing:
		if pressed_tween && pressed_tween.is_running():
			pressed_tween.kill()
			pressed_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
			pressed_tween.tween_property(bg_pressed, 'modulate:a', pressed_alpha, 0.25 * bg_pressed.modulate.a)
			pressed_tween.tween_property(bg_pressed, 'rect_scale', Vector2(1, 1), 0.25 * bg_pressed.modulate.a)
			pressed_tween.chain().tween_property(bg_pressed, 'modulate:a', 0.0, 0.25)
		else:
			pressed_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			pressed_tween.tween_property(bg_pressed, 'modulate:a', 0.0, 0.25)
		pressing = false


func _on_button_toggled(button_pressed: bool):
	emit_signal("toggled", button_pressed)
	_update_label()

extends Button

export var cost = 15 setget set_cost
export var label_text = ""
export var bg_icon: Texture
export var bg_color = Color('#1d1120')
export var bg_hover_color = Color('#130b15')
export var bg_border_color = Color('#000000')
export var bg_hover_border_color = Color('#bb0fc5')

onready var bg_material = $bg.material
onready var label_cost = $label_cost
onready var label = $label


func _ready():
	bg_material.set_shader_param('color', bg_color)
	bg_material.set_shader_param('border_color', bg_border_color)
	label_cost.text = str(cost)
	label.text = label_text
	if bg_icon:
		$bg_icon.texture = bg_icon


func _draw():
	var alpha = 1
	if disabled:
		alpha = 0.5
		focus_mode = Control.FOCUS_NONE
	else:
		focus_mode = Control.FOCUS_ALL
	$icon.modulate.a = alpha
	$label.modulate.a = alpha
	$label_cost.modulate.a = alpha


func set_cost(value):
	cost = value
	if label_cost:
		label_cost.text = str(cost)


func _on_button_focus_entered():
	bg_material.set_shader_param('color', bg_hover_color)
	bg_material.set_shader_param('border_color', bg_hover_border_color)


func _on_button_focus_exited():
	bg_material.set_shader_param('color', bg_color)
	bg_material.set_shader_param('border_color', bg_border_color)


func _on_button_mouse_entered():
	if disabled:
		return
	var focus_control = get_focus_owner()
	if focus_control && focus_control != self:
		focus_control.release_focus()
	grab_focus()

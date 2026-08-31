extends Popup

export var label_text = "..." setget set_label_text
export var transparent = true setget set_transparent

var last_focused
var default_alpha = null

onready var label_node = $label
onready var bg_node = $bg

func _ready():
	label_node.text = label_text
	Global.theme_bg_overlay(bg_node)
	default_alpha = bg_node.modulate.a


func set_label_text(value):
	label_text = value
	if label_node:
		label_node.text = value


func set_transparent(value):
	transparent = value
	if bg_node:
		bg_node.modulate.a = 1 if !transparent else default_alpha


func open():
	last_focused = get_focus_owner()
	if is_instance_valid(last_focused):
		last_focused.release_focus()
	popup()


func _on_loading_popup_hide():
	if !is_instance_valid(last_focused):
		return
	if !is_instance_valid(get_focus_owner()):
		last_focused.grab_focus()

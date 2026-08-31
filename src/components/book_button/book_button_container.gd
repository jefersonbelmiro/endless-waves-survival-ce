extends Control

export var disabled = false

var _last_focus_control


func _ready():
	connect("hide", self, "_on_hide")
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")


func _on_hide():
	_last_focus_control = null


func _on_gui_focus_changed(control):
	if !control || !visible:
		return 

	if control == _last_focus_control:
		return

	if !disabled && _is_child(control) && _is_child(_last_focus_control):
		var button = _get_button(control)
		yield(get_tree(), 'idle_frame')
		if is_instance_valid(button) && (!'pressing' in button || !button.pressing):
			SFX.add_button_focus()
			
	_last_focus_control = control
		

func _is_child(control):
	if !is_instance_valid(control) || !control.is_inside_tree() || !is_inside_tree():
		return false
	return str(control.get_path()).begins_with(str(get_path()))


func _get_button(control):
	if control is Button:
		return control
	return control.get_child(0)

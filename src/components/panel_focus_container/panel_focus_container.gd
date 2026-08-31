extends Control

export var disabled = false
export var current_panel = -1
export (Array, NodePath) var panels = []
export (Array, NodePath) var panels_focus_containers = []

var _last_focus_control = []
var _absolute_path = []
var _effect_control: NinePatchRect
var _effect_tween: SceneTreeTween


func _ready():
	_effect_control = NinePatchRect.new()
	_effect_control.patch_margin_left = 5
	_effect_control.patch_margin_top = 5
	_effect_control.patch_margin_right = 5
	_effect_control.patch_margin_bottom = 5
	_effect_control.texture = load("res://assets/components/simple_border_box.png")
	_effect_control.modulate = Color("#9c00be")

	for index in panels.size():
		var panel = get_node(panels[index])
		var path = str(panel.get_path())
		_absolute_path.append(path)

	_last_focus_control.resize(panels.size())

	set_process_input(false)
	connect("visibility_changed", self, "_on_visibility_changed")
	if owner is Popup:
		Global.connect("opened_popups_changed", self, "_on_opened_popups_changed")


func _input(event: InputEvent) -> void:
	if disabled || !is_visible_in_tree():
		return
	if event.is_action_pressed("ui_select_next"):
		_set_active_panel(wrapi(current_panel + 1, 0, panels.size()))
		SFX.add_button_pressed()
	elif event.is_action_pressed("ui_select_prev"):
		_set_active_panel(wrapi(current_panel - 1, 0, panels.size()))
		SFX.add_button_pressed()


func _on_visibility_changed():
	var is_connected = get_viewport().is_connected("gui_focus_changed", self, "_on_gui_focus_changed")
	var is_visible = is_visible()
	if is_visible && !is_connected:
		set_process_input(true)
		get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")
	elif !is_visible && is_connected:
		set_process_input(false)
		get_viewport().disconnect("gui_focus_changed", self, "_on_gui_focus_changed")


func _on_opened_popups_changed():
	# wait popup to be visible
	if !is_inside_tree():
		return
	get_tree().create_timer(0.1).connect("timeout", self, "_on_visibility_changed")


func _on_gui_focus_changed(control):
	if !control || !is_visible_in_tree():
		return 

	var control_path = str(control.get_path())
	for index in _absolute_path.size():
		var path = _absolute_path[index]
		if control_path.begins_with(path):
			current_panel = index
			_last_focus_control[index] = control
			break


func is_visible():
	if !is_visible_in_tree():
		return false
	if owner is Popup:
		var index = Global.opened_popups.find(owner)
		if index != -1 && index == Global.opened_popups.size() - 1:
			return true
	return false


func _set_active_panel(index: int):
	if current_panel == index:
		return
	current_panel = index

	_create_active_effect()

	var last_focus = _last_focus_control[current_panel]
	if is_instance_valid(last_focus) && last_focus.is_visible_in_tree():
		last_focus.grab_focus()
	else:
		var path = panels_focus_containers[current_panel]
		var control = get_node(path)
		for index in control.get_child_count():
			var child = control.get_child(index)
			if child.is_visible_in_tree() && child.focus_mode != FOCUS_NONE:
				child.grab_focus()
				break


func _create_active_effect():
	var panel = get_node(panels[current_panel])

	_effect_control.modulate.a = 1
	if !_effect_tween:
		_effect_tween = create_tween()
	else:
		_effect_tween.kill()
		_effect_tween = create_tween()
	_effect_tween.tween_property(_effect_control, 'modulate:a', 0.0, 0.15).set_delay(0.6)

	if _effect_control.is_inside_tree():
		_effect_control.get_parent().remove_child(_effect_control)
	panel.add_child(_effect_control)
	_effect_control.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	



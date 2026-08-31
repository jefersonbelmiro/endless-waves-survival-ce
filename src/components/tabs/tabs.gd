extends Control

signal tab_changed(tab_index)

export var disabled = false

var button_bg_texture = preload("res://src/components/tabs/texture/button_bg.png")
var button_selected_bg_texture = preload("res://src/components/tabs/texture/button_selected_bg.png")
var button_box_fg = preload("res://src/components/tabs/texture/button_box_fg.png")
var current_tab = -1
var tabs_size = 0

var _default_config = {
	button_size = Vector2(50, 18),
	button_font = 8,
}

var _mobile_config = {
	button_size = Vector2(80, 32),
	button_font = 16,
}

var _config = _default_config

onready var header = $container/header/content
onready var content = $container/content
onready var ui_select_next = $ui_select_next
onready var ignore = [
	$bg_color,
	$border,
	$ui_select_prev,
	$ui_select_next,
	$container,
]


func _ready():
	if Global.is_mobile():
		_config = _mobile_config
		$ui_select_prev.hide()
		$ui_select_next.hide()

	$container/header.rect_min_size.y = _config.button_size.y
	$bg_color.margin_top = _config.button_size.y
	$border.margin_top = _config.button_size.y 

	var reparent = []
	for index in get_child_count():
		var node = get_child(index)
		if ignore.has(node):
			continue
		reparent.append(node)

	
	for index in reparent.size():
		remove_child(reparent[index])
		add_child(reparent[index])
		
	tabs_size = reparent.size()
	_set_active_tab(0)
	
	Global.theme_panel_bg($bg_color)
	Global.theme_panel_border($border)


func _input(event: InputEvent) -> void:
	if disabled || !is_visible_in_tree():
		return
	if event.is_action_pressed("ui_select_next") && current_tab + 1 < tabs_size:
		_set_active_tab(current_tab + 1)
		SFX.add_button_pressed()
	elif event.is_action_pressed("ui_select_prev") && current_tab > 0:
		_set_active_tab(current_tab - 1)
		SFX.add_button_pressed()


func add_child(node: Node, unique_name = false) -> void:
	if !is_inside_tree():
		.add_child(node, unique_name)
		return
	var button = Global.box_button_scene.instance()
	button.text_label = node.name
	button.rect_min_size = _config.button_size
	button.font_size = _config.button_font
	button.focus_mode = FOCUS_NONE
	button.toggle_mode = true
	button.border_texture = button_bg_texture
	button.get_node("bg_color").texture = button_box_fg
	button.get_node("bg_pressed").texture = button_box_fg
#	button.pressed_color = Color("#251625")
#	button.get_node("bg_color").margin_bottom = -2
#	button.get_node('bg').modulate = Color(1, 1, 1)
	button.connect("pressed", self, "_on_button_pressed", [button])
	header.add_child(button)
	
	var content_container = Control.new()
	content_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	content_container.margin_top = 0
	content_container.margin_left = 10
	content_container.margin_right = -10
	content_container.margin_bottom = -10
	content_container.add_child(node, unique_name)
	content_container.hide()
	node.show()
	content.add_child(content_container)


func get_tab_content(tab_index: int):
	return content.get_child(tab_index).get_child(0)


func get_tab_node(tab_index: int, path: String):
	return content.get_child(tab_index).get_node_or_null(path)


func _set_active_tab(tab_index: int):
	var diff = tab_index != current_tab
	current_tab = tab_index
	for index in content.get_child_count():
		var tab_button = header.get_child(index)
		var tab_content = content.get_child(index)
		if index == tab_index:
			tab_content.show()
			tab_button.pressed = true
			tab_button.border_texture = button_selected_bg_texture
		else:
			tab_button.pressed = false
			tab_button.border_texture = button_bg_texture
			tab_content.hide()
	if diff:
		emit_signal("tab_changed", current_tab)


func _fix_input_icon_positions():
	if header.get_child_count() == 0:
		return
	var last_button : Button = header.get_child(header.get_child_count() - 1)
	var position = last_button.rect_size.x + last_button.rect_global_position.x
	ui_select_next.rect_global_position.x = position + 6
	

func _on_button_pressed(node):
	_set_active_tab(node.get_index())


func _on_content_draw():
	_fix_input_icon_positions()


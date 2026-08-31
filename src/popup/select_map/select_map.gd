extends Popup

var button_scene = preload("res://src/popup/select_map/components/button/map_button.tscn")
var persist_data = false
var selected_map_id

var _default_config = {
	actions_height = 20,
	container_magin_bottom = -10,
	selected_actions_size = Vector2(20, 20),
	map_button_size = Vector2(40, 40),
	map_button_font = 8,
	label_font = 12,
	description_font = 12,
	level_label_font = 12,
	selected_level_button_size = Vector2(20, 20),
	selected_mode_button_size = Vector2(20, 20),
}

var _mobile_config = {
	actions_height = 32,
	container_magin_bottom = -4,
	selected_actions_size = Vector2(32, 32),
	map_button_size = Vector2(80, 80),
	map_button_font = 16,
	description_font = 14,
	label_font = 12,
	level_label_font = 12,
	selected_level_button_size = Vector2(32, 32),
	selected_mode_button_size = Vector2(32, 32),
}

var _config = _default_config

onready var maps_controls = $container/content/maps/grid
onready var map_icon = $container/content/selected/content/header/icon_container/icon
onready var map_label = $container/content/selected/content/header/label_container/label
onready var map_description = $container/content/selected/content/scroll_container/margin_container/content/description_container/label
onready var map_levels_container = $container/content/selected/content/scroll_container/margin_container/content/levels
onready var map_levels_label = $container/content/selected/content/scroll_container/margin_container/content/levels/label
onready var map_mode_label = $container/content/selected/content/scroll_container/margin_container/content/mode/label
onready var map_mode_buttons = $container/content/selected/content/scroll_container/margin_container/content/mode/buttons
onready var map_levels_buttons = $container/content/selected/content/scroll_container/margin_container/content/levels/buttons

func _ready():
	if Global.is_mobile():
		_config = _mobile_config
		$container/actions_hint.hide()
	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")
	
	Global.theme_bg($bg)
	Global.theme_panel_bg($container/content/maps/bg)
	Global.theme_panel_border($container/content/maps/bg_border)
	Global.theme_panel_bg($container/content/selected/bg)
	Global.theme_panel_border($container/content/selected/bg_border)

	maps_controls.item_size = _config.map_button_size.x
	$container.margin_bottom = _config.container_magin_bottom
	$container/actions.rect_min_size.y = _config.actions_height
	$container/actions/done_button.rect_min_size.y = _config.actions_height


func open():
	Global.opened_popups_add(self)
	popup()

	if selected_map_id == null:
		selected_map_id = Persistent.get_data('selected_map_id')

	maps_controls.clear()
	
	var maps = Entities.get_maps_data()
	for index in maps.size():
		var map = maps[index]

		if 'visible' in map:
			if typeof(map.visible) == TYPE_STRING && map.visible == 'editor' && !OS.is_debug_build():
				continue
			elif !map.visible:
				continue

		var node = button_scene.instance()
		node.toggle_mode = true
		node.name = map.id
		node.icon_texture = Global.get_map_icon(map.id)
		node.text_label = map.label
		node.rect_min_size = _config.map_button_size
		node.font_size = _config.map_button_font
		node.connect("pressed", self, "_on_map_pressed", [map.id])
		node.connect("focus_entered", self, "_on_map_focus_entered", [map])
		maps_controls.add_child(node)

		if map.id == selected_map_id:
			_on_map_focus_entered(map)

	# @FIXME workaround to ScrollContainer follow_focus
	# wait popup to grab focus
	yield(get_tree(), 'idle_frame')
	maps_controls.get_node_or_null(selected_map_id).pressed = true
	maps_controls.get_node_or_null(selected_map_id).grab_focus()


func _on_map_pressed(map_id):
	if !persist_data && map_id != selected_map_id:
		persist_data = true
	selected_map_id = map_id
	for index in maps_controls.get_child_count():
		var node = maps_controls.get_child(index)
		node.pressed = map_id == node.name
	if !InputSource.mouse && !Global.is_mobile():
		map_mode_buttons.get_child(0).grab_focus()


func _on_map_focus_entered(map_data):
	map_data.load_persisted()
	if map_data.levels <= 1:
		map_levels_container.hide()
	else:
		map_levels_container.show()
		Global.node_remove_children(map_levels_buttons)
		for index in map_data.levels:
			var button = Global.box_button_scene.instance()
			button.toggle_mode = true
			button.name = str(index + 1)
			button.pressed = map_data.level == index + 1
			button.disabled = map_data.unlock_level < index + 1
			button.rect_min_size = _config.selected_level_button_size
			button.font_size = 12
			button.text_label = str(index + 1)
			button.connect("focus_entered", self, "_on_map_level_focus_entered", [map_data,  index + 1])
			button.connect("pressed", self, "_on_map_level_pressed", [map_data.id, index + 1])
			map_levels_buttons.add_child(button)

	Global.node_remove_children(map_mode_buttons)

	var endless_button = _create_map_action({
		icon = load("res://assets/icons/endless_icon.png"),
		mode = Global.MAP_MODES.ENDLESS,
		pressed = map_data.mode == Global.MAP_MODES.ENDLESS,
		hint = "ENDLESS",
	})
	endless_button.connect("pressed", self, "_on_map_mode_pressed", [map_data, Global.MAP_MODES.ENDLESS])
	map_mode_buttons.add_child(endless_button)

	var objective_button = _create_map_action({
		icon = load("res://assets/icons/objective_icon.png"), 
		mode = Global.MAP_MODES.OBJECTIVES,
		pressed = map_data.mode == Global.MAP_MODES.OBJECTIVES,
		hint = "OBJECTIVES",
	})
	objective_button.connect("pressed", self, "_on_map_mode_pressed", [map_data, Global.MAP_MODES.OBJECTIVES])
	map_mode_buttons.add_child(objective_button)

	_update_selected_map(map_data)


func _create_map_action(options):
	var node = Global.box_button_scene.instance()
	node.icon_color = Color("#acaaaa")
	node.icon_texture = options.icon
	node.rect_min_size = _config.selected_mode_button_size
	node.toggle_mode = true
	node.name = str(options.mode)
	node.pressed = options.pressed
	node.font_size = 8
	node.hint_tooltip = options.hint
	return node


func _on_map_mode_pressed(map_data, mode: int):
	var map_meta = Persistent.get_map(map_data.id)
	if map_meta.mode != mode:
		persist_data = true
		Persistent.map_select_mode(map_data.id, mode)
	for index in map_mode_buttons.get_child_count():
		var button = map_mode_buttons.get_child(index)
		button.pressed = str(mode) == button.name
	_update_selected_map(map_data)


func _update_selected_map(map_data):
	map_icon.texture = Global.get_map_icon_bg(map_data.id)
	map_label.text = map_data.label

	var map_meta = Persistent.get_map(map_data.id)
	if map_meta.mode == Global.MAP_MODES.ENDLESS:
		map_description.bbcode_text = tr("SURVIVE_AS_LONG_AS_YOU_CAN")
	else:
		map_description.bbcode_text = map_data.format_objectives()


func _on_map_level_focus_entered(map_data, level: int):
	var map_clone = map_data.duplicate()
	map_clone.level = level
	_update_selected_map(map_clone)


func _on_map_level_pressed(map_id: String, level: int):
	var map_meta = Persistent.get_map(map_id)
	if map_meta.level != level && map_meta.unlock_level >= level:
		persist_data = true
		Persistent.map_select_level(map_id, level)
	for index in map_levels_buttons.get_child_count():
		var button = map_levels_buttons.get_child(index)
		button.pressed = map_meta.level == index + 1


func _on_done_button_pressed():
	hide()


func _on_select_map_popup_hide():
	Global.opened_popups_remove(self)
	if persist_data:
		Persistent.set_data('selected_map_id', selected_map_id)
		Persistent.save_data()


func _on_language_changed():
	map_description.set('custom_fonts/normal_font', Global.get_font(_config.description_font))
	map_levels_label.set('custom_fonts/font', Global.get_font(_config.level_label_font))
	map_mode_label.set('custom_fonts/font', Global.get_font(_config.label_font))

	map_levels_label.text = "%s:" % [tr("LEVEL")]
	map_mode_label.text = "%s:" % [tr("MODE")]

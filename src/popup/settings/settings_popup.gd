extends Popup

enum TABS { GENERAL, GAME, EFFECTS, AUDIO, CONTROLLER }

# general
var fullscreen_control
var switch_version_control
var camera_zoom_control
var auto_levelup_control
var enemy_health_bar_control
var autocast_icons_control
var activate_portal_control
var language_control
var crosshair_control
var aim_mode_control
var aim_mode_hint
var score_name_label

# effects
var particle_effect_control
var glow_effect_control
var floating_text_control

# audio
var music_volume_control
var sfx_volume_control

# controller
var controller_devices_control
var controller_devices_empty_label
var controller_container

var locales = []
var joypads = []
var aim_modes = ["auto", "crosshair", "direction"]
var bad_words_filter

var _default_config = {
	actions_height = 20,
}

var _mobile_config = {
	actions_height = 32,
}

var _config = _default_config

onready var back_button = $actions/back_button
onready var tabs = $tabs_container/tabs

func _ready():
	if Global.is_mobile():
		_config = _mobile_config

	# general
	fullscreen_control = tabs.get_tab_node(0, "GENERAL/controls/fullscreen/fullscreen_control")
	switch_version_control = tabs.get_tab_node(0, "GENERAL/controls/switch_version/switch_version_control")
	language_control = tabs.get_tab_node(0, "GENERAL/controls/language/language_control")
	score_name_label = tabs.get_tab_node(0, "GENERAL/controls/score_name/control_container/label")
	
	# game
	auto_levelup_control = tabs.get_tab_node(1, "GAME/controls/auto_levelup/auto_levelup_control")
	enemy_health_bar_control = tabs.get_tab_node(1, "GAME/controls/enemy_health_bar/enemy_health_bar_control")
	autocast_icons_control = tabs.get_tab_node(1, "GAME/controls/autocast_icons/autocast_icons_control")
	activate_portal_control = tabs.get_tab_node(1, "GAME/controls/activate_portal/activate_portal_control")
	camera_zoom_control = tabs.get_tab_node(1, "GAME/controls/camera_zoom/camera_zoom_control")
	crosshair_control = tabs.get_tab_node(1, "GAME/controls/crosshair/crosshair_control")
	aim_mode_control = tabs.get_tab_node(1, "GAME/controls/aim_mode/aim_mode_control") 
	aim_mode_hint = tabs.get_tab_node(1, "GAME/controls/aim_mode/label/hint") 
	aim_mode_control.selected = aim_modes.find(Settings.get_aim_mode())

	# effects
	particle_effect_control = tabs.get_tab_node(2, "EFFECTS/controls/particle_effect/particle_effect_control")
	glow_effect_control = tabs.get_tab_node(2, "EFFECTS/controls/glow_effect/glow_effect_control")
	floating_text_control = tabs.get_tab_node(2, "EFFECTS/controls/floating_text/floating_text_control")

	# audio
	music_volume_control = tabs.get_tab_node(3, "AUDIO/controls/music_volume/music_volume_control")
	sfx_volume_control = tabs.get_tab_node(3, "AUDIO/controls/sfx_volume/sfx_volume_control")

	# controller
	controller_devices_control = tabs.get_tab_node(4, "CONTROLLER/controls/controller_devices/controller_devices_control")
	controller_devices_empty_label = tabs.get_tab_node(4, "CONTROLLER/controls/controller_devices/empty_label")
	controller_container = tabs.get_tab_node(4, "CONTROLLER")

	if !Global.has_full_screen():
		tabs.get_tab_node(0, "GENERAL/controls/fullscreen").hide() 

	locales = TranslationServer.get_loaded_locales()
	for id in locales:
		var name = TranslationServer.get_locale_name(id).to_upper()
		language_control.add_item(name)

	switch_version_control.clear()
	switch_version_control.add_item(tr("SWITCH_VERSION_NEW").format({ version = Version.CURRENT }))
	switch_version_control.add_item(tr("SWITCH_VERSION_OLD").format({ version = 'v0.2.4' }))
	
	# general
	fullscreen_control.pressed = Settings.get_fullscreen()
	switch_version_control.selected = 0
	language_control.selected = locales.find(Settings.get_language())

	
	if Settings.get_aim_mode() == 'crosshair':
		tabs.get_tab_node(1, "GAME/controls/crosshair").show()
	else:
		tabs.get_tab_node(1, "GAME/controls/crosshair").hide()

	_update_crosshair()
	_on_update_language()

	var activate_portal_modes = Global.ACTIVATE_PORTAL_MODES.keys()
	var activate_portal_selected_id = 0
	for idx in activate_portal_modes.size():
		var name = activate_portal_modes[idx]
		if Global.is_mobile() && name == 'ACTION':
			continue
		if idx == Settings.get_activate_portal():
			activate_portal_selected_id = idx
		activate_portal_control.add_item(name, idx)

	# game
	auto_levelup_control.pressed = Settings.get_auto_levelup()
	enemy_health_bar_control.pressed = Settings.get_enemy_health_bar()
	autocast_icons_control.pressed = Settings.get_autocast_icons()
	activate_portal_control.selected = activate_portal_control.get_item_index(activate_portal_selected_id)
	camera_zoom_control.value = Settings.get_camera_zoom()
	camera_zoom_control.get_child(0).text = _get_camera_zoom_label(Settings.get_camera_zoom())

	# effects
	particle_effect_control.pressed = Settings.get_particle_effect()
	floating_text_control.pressed = Settings.get_floating_text()
	glow_effect_control.pressed = Settings.get_glow_effect()

	# audio
	music_volume_control.value = Settings.get_music_volume()
	sfx_volume_control.value = Settings.get_sfx_volume()

	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	
	Global.theme_bg($bg)

	$actions.rect_min_size.y = _config.actions_height 
	back_button.rect_min_size.y = _config.actions_height
	$actions.set_anchors_and_margins_preset(PRESET_CENTER_BOTTOM)
	$actions.margin_top = -_config.actions_height - 4


func open():
	Global.opened_popups_add(self, { popup_tween_finished_func_ref = funcref(self, "_on_popup_tween_finished") })
	popup()
	if tabs.current_tab != -1:
		_set_container_focus(tabs.get_tab_content(tabs.current_tab))
	back_button.grab_focus()
	
	var score_data = Persistent.get_score_data()
	if 'user_name' in score_data && score_data.user_name:
		score_name_label.text = score_data.user_name


func _set_controller_devices():
	controller_devices_control.clear()
	joypads.clear()
	var connected_joypads = Input.get_connected_joypads() 
	var selected_index = -1

	for index in connected_joypads.size():
		var device_id = connected_joypads[index]
		var device_guid = Input.get_joy_guid(device_id)
		if !Input.is_joy_known(device_id):
			continue
		var joy = { id = device_id, name = Input.get_joy_name(device_id) }
		joypads.append(device_guid)
		controller_devices_control.add_item(joy.name)
		if device_guid == Settings.get_controller_device():
			selected_index = joypads.find(device_guid)
	
	if selected_index >= 0:
		controller_devices_control.selected = selected_index

	controller_devices_control.visible = joypads.size() > 0
	controller_devices_empty_label.visible = joypads.size() == 0


func _set_container_focus(container, focus_first_control = true):
	var controls = container.get_node('controls')
	var first_control = controls.get_child(0).get_child(1)

	var last_control_parent
	for index in range(controls.get_child_count() - 1, 0, -1):
		last_control_parent = controls.get_child(index) 
		if last_control_parent.is_visible_in_tree():
			break

	if is_instance_valid(last_control_parent):
		var last_control = last_control_parent.get_child(1)
		if !last_control.name.ends_with("_control"):
			last_control = last_control_parent.find_node("*_control", true, false)
		if is_instance_valid(last_control) && last_control.is_visible_in_tree():
			last_control.focus_neighbour_bottom = back_button.get_path()
			back_button.focus_neighbour_top = last_control.get_path()

	if focus_first_control:
		if is_instance_valid(first_control) && first_control.is_visible_in_tree():
			first_control.grab_focus()
		else:
			back_button.focus_neighbour_top = ""
			back_button.grab_focus()


func _update_crosshair():
	var sprite = crosshair_control.get_node("sprite")
	var data = Settings.get_crosshair()
	sprite.texture = load("res://assets/input/crosshair/crosshair%s.png" % [data.image_index])
	sprite.modulate = Color(data.color)


func _on_music_control_value_changed(value):
	Settings.set_music_volume(value)
	Settings.save_settings()


func _on_sound_control_value_changed(value):
	Settings.set_sfx_volume(value)
	Settings.save_settings()


func _on_particle_effect_control_toggled(button_pressed):
	Settings.set_particle_effect(button_pressed)
	Settings.save_settings()


func _on_glow_effect_control_toggled(button_pressed):
	Settings.set_glow_effect(button_pressed)
	Settings.save_settings()


func _on_floating_text_control_toggled(button_pressed):
	Settings.set_floating_text(button_pressed)
	Settings.save_settings()


func _on_fullscreen_control_toggled(button_pressed):
	Settings.set_fullscreen(button_pressed)
	Settings.save_settings()


func _on_switch_version_control_item_selected(index):
	var use_new_version = index == 0
	switch_version_control.selected = 1 if use_new_version else 0
	var confirm_popup = Global.add_confirm("SWITCH_VERSION_CONFIRM", Vector2(260, 120))
	confirm_popup.label.connect("meta_clicked", self, "_on_switch_version_meta_clicked")
	confirm_popup.get_node("container/content/actions/confirm_button").queue_free()
	confirm_popup.get_node("container/content/actions/cancel_button").text_label = "CLOSE"


func _on_switch_version_meta_clicked(meta):
	OS.shell_open(meta);


func _on_camera_zoom_control_value_changed(value):
	camera_zoom_control.get_child(0).text = _get_camera_zoom_label(value)
	Settings.set_camera_zoom(value)
	Settings.save_settings()


func _on_auto_levelup_control_toggled(button_pressed):
	Settings.set_auto_levelup(button_pressed)
	Settings.save_settings()


func _on_enemy_health_bar_control_toggled(button_pressed):
	Settings.set_enemy_health_bar(button_pressed)
	Settings.save_settings()


func _on_autocast_icons_control_toggled(button_pressed):
	Settings.set_autocast_icons(button_pressed)
	Settings.save_settings()


func _on_activate_portal_control_item_selected(index):
	var idx = activate_portal_control.get_item_id(index)
	Settings.set_activate_portal(idx)
	Settings.save_settings()


func _on_language_control_item_selected(index):
	Settings.set_language(locales[index])
	Settings.save_settings()
	_on_update_language()


func _on_controller_devices_control_item_selected(index):
	Settings.set_controller_device(joypads[index])
	Settings.save_settings()


func _on_aim_mode_control_item_selected(index):
	Settings.set_aim_mode(aim_modes[index])
	Settings.save_settings()
	if Settings.get_aim_mode() == 'crosshair':
		tabs.get_tab_node(1, "GAME/controls/crosshair").show()
	else:
		tabs.get_tab_node(1, "GAME/controls/crosshair").hide()


func _on_crosshair_control_pressed():
	$crosshair_setting_popup.open()


func _on_crosshair_setting_popup_changed(data):
	Settings.set_crosshair(data)
	Settings.save_settings()
	_update_crosshair()


func _on_update_language():
	switch_version_control.set('custom_fonts/font', Global.get_font(12))   
	language_control.set('custom_fonts/font', Global.get_font(12))  
	activate_portal_control.set('custom_fonts/font', Global.get_font(12))  
	controller_devices_control.set('custom_fonts/font', Global.get_font(12))   
	aim_mode_control.set('custom_fonts/font', Global.get_font(12))   
	aim_mode_hint.set('custom_fonts/font', Global.get_font(10))   


func _on_joy_connection_changed(_device_id: int, _connected: bool):
	if visible:
		_set_controller_devices()
		_set_container_focus(controller_container)


func _on_back_button_pressed():
	hide()


func _on_settings_popup_hide():
	Global.opened_popups_remove(self)


func _on_tabs_tab_changed(tab_index):
	if !visible:
		return
	if tab_index == TABS.CONTROLLER:
		_set_controller_devices()
	if !tabs:
		# wait enter tree to get tabs node
		yield(get_tree(), 'idle_frame')
	_set_container_focus(tabs.get_tab_content(tab_index))


func _on_popup_tween_finished():
	tabs._fix_input_icon_positions()


func _get_camera_zoom_label(value):
	var label_value = value + 1 if value >= 0 else value - 1
	return "%sx" % [label_value]
	


func _on_score_name_button_pressed():
	tabs.disabled = true
	var node = Global.add_score_edit_popup()
	node.connect("edited", self, "_on_score_name_edited", [], CONNECT_ONESHOT)
	node.connect("hide", tabs, 'set_deferred', ['disabled', false], CONNECT_ONESHOT)


func _on_score_name_edited(name: String):
	if !is_instance_valid(bad_words_filter):
		bad_words_filter = Global.bad_words_filter.instance()
		add_child(bad_words_filter)

	# valide profanity
	var valid = bad_words_filter.validate(name)
	if !valid:
		Global.add_toast_error(tr("LEADERBOARD_UPDATE_NAME_ERROR_PROFANITY"))
		return

	var current_name = score_name_label.text
	score_name_label.text = name
	var result = yield(Firebase.update_user_name(name), 'completed')
	if FP.safe_get(result, 'error'):
		score_name_label.text = current_name
		Global.add_toast_error(tr("LEADERBOARD_UPDATE_NAME_ERROR"))



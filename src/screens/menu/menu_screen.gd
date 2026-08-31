extends Node2D

var _default_config = {
	actions_height = 20,
}

var _mobile_config = {
	actions_height = 32,
}

var _config = _default_config

onready var button_container = $hud/control/container/buttons/button_container
onready var play_button = $hud/control/container/buttons/button_container/play_button
onready var loading_popup = $hud/loading_popup

func _ready():
	Global.delay_func(self, '_on_init')

	if Global.is_mobile():
		_config = _mobile_config
	Global.set_paused(false)
	
	$hud/control/bg.color = Global.THEME_CONFIG.bg_color

	play_button.grab_focus()
	Global.hud_toast_container = get_node("front_layer/toast_container")
	
	get_tree().set_auto_accept_quit(true)

	if !Global.has_quit():
		button_container.get_node("quit_button").hide()

	if Global.is_mobile():
		button_container.get_node("help_button").hide()

	for index in button_container.get_child_count():
		var node = button_container.get_child(index)
		if node.name == 'separator':
			continue
		node.rect_min_size.y = _config.actions_height
	button_container.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	
	_fetch_version()


func _input(event):
	# set non default controller to current device
	if event is InputEventJoypadMotion || event is InputEventJoypadButton:
		if event.device != Global.session.controller_device:
			Global.set_controller_device(event.device)


func _fetch_version():
	$hud/control/container/version_label.text = Version.CURRENT


func _on_play_button_pressed():
	if Persistent.loaded:
		_on_open_new_game()
	else:
		loading_popup.open()
		Persistent.connect("loaded", self, "_on_open_new_game")


func _on_open_new_game():
	if loading_popup.visible:
		get_tree().create_timer(0.3).connect("timeout", loading_popup, "hide")
	$hud/new_game_popup.open()


func _on_quit_button_pressed():
	Global.quit()


func _on_settings_button_pressed():
	$hud/settings_popup.open()


func _on_editor_button_pressed():
	$hud/editor_popup.open()


func _on_help_button_pressed():
	$hud/help_popup.open()


func _on_new_game_popup_hide():
	play_button.grab_focus()


func _on_discord_button_pressed():
	OS.shell_open("https://discord.com/invite/93VMMCBbtf")


func _on_init():
	Global.connect("plataform_initialized", self, "_on_plataform_initialized")
	Global.persistent_load_connect(self, '_on_persisted_loaded')
	Global.init_plataform_sdk()


func _on_plataform_initialized():
	Persistent.load_data()


func _on_persisted_loaded():
	Firebase.init()



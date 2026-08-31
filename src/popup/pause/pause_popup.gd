extends Popup

var _default_config = {
	container_margin_top = 40,
	actions_size = Vector2(88, 20),
}

var _mobile_config = {
	container_margin_top = 5,
	actions_size = Vector2(120, 32),
}

var _config = _default_config
var _resume_main_music = true

onready var settings_popup = $settings_popup
onready var help_popup = $help_popup
onready var sfx_open = $sfx_open
onready var sfx_close = $sfx_close
onready var button_container = $button_container
onready var resume_button = $button_container/resume_button
onready var player_cards = $container/player_cards
onready var player_stats = $container/player_stats

func _ready():
	if Global.is_mobile():
		_config = _mobile_config
		button_container.get_node("help_button").hide()
		$container/player_cards.size_flags_horizontal = SIZE_EXPAND_FILL
		$container/player_stats.size_flags_horizontal = SIZE_EXPAND_FILL

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")

	for index in button_container.get_child_count():
		var node = button_container.get_child(index)
		node.rect_min_size = _config.actions_size
		if !Global.is_mobile():
			node.focus_neighbour_left = player_cards.get_path()
	button_container.set_anchors_and_margins_preset(PRESET_CENTER)
	$container.margin_top = _config.container_margin_top


func open():
	# workaround to ignore ui_cancel action
	yield(get_tree(), "idle_frame")
	
	Global.opened_popups_add(self, { popup_tween = false })
	popup()
	sfx_open.play()
	# Global.set_paused(true)
	# AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	Global.stop_main_music()

	player_cards.update()
	player_stats.update()
	resume_button.grab_focus()


func _on_resume_button_pressed():
	hide()


func _on_menu_button_pressed():
	_resume_main_music = false
	hide()
	Global.emit_signal("player_quit")
	

func _on_settings_button_pressed():
	settings_popup.open()


func _on_pause_popup_popup_hide():
	Global.opened_popups_remove(self)
	# Global.set_paused(false)
	# AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), Settings.has_music_muted())
	if _resume_main_music:
		Global.resume_main_music()
	sfx_close.play()


func _on_language_changed():
	# recenters because the size may vary depending on the language
	button_container.set_anchors_and_margins_preset(Control.PRESET_CENTER)

	$title.set('custom_fonts/font', Global.get_font(40))


func _on_help_button_pressed():
	help_popup.open()


extends Popup

var button_scene = preload("res://src/popup/new_game/components/button/big_button.tscn")

var _default_config = {
	actions_height = 20,
}

var _mobile_config = {
	actions_height = 32,
}

var _config = _default_config

onready var char_button = $container/content/char/char_button
onready var char_label = $container/content/char/label_container/label
onready var map_button = $container/content/map/map_button
onready var map_label = $container/content/map/label_container/label
onready var backpack_label = $container/content/backpack/label_container/label
onready var backpack_button = $container/content/backpack/backpack_button

onready var traits_label = $container/content/traits/label_container/label
onready var traits_button = $container/content/traits/traits_button

onready var back_button = $container/actions/back_button
onready var play_button = $container/actions/play_button

func _ready():
	if Global.is_mobile():
		_config = _mobile_config

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")
	
	Global.theme_bg($bg)
	Global.theme_button($container/content/char/char_button)
	Global.theme_button($container/content/map/map_button)
	Global.theme_button($container/content/backpack/backpack_button)
	Global.theme_button($container/content/traits/traits_button)

	$container/actions.rect_min_size.y = _config.actions_height
	back_button.rect_min_size.y = _config.actions_height
	play_button.rect_min_size.y = _config.actions_height


func open():
	Global.opened_popups_add(self)
	popup()
	_update_buttons()
	play_button.grab_focus()


func _update_buttons():
	var char_id = Persistent.get_data("selected_char_id")
	var char_data = Entities.create_char_data(char_id)
	char_button.text_label = char_data.label
	char_button.icon_texture = Global.chars_icons[char_id]

	var map_id = Persistent.get_data("selected_map_id")
	var map_data = Database.get_map(map_id)
	map_button.text_label = map_data.label
	map_button.icon_texture = Global.get_map_icon(map_id)
	
	backpack_button.text_label = "%s %s" % [Persistent.get_backpack_total_items(), tr("ITEMS_PLURAL")]
	traits_button.text_label = "%s %s" % [Persistent.get_traits_total_items(), tr("ITEMS_PLURAL")]


func _on_char_button_pressed():
	$select_char_popup.open()


func _on_map_button_pressed():
	$select_map_popup.open()


func _on_backpack_button_pressed():
	$backpack_edit_popup.open()


func _on_traits_button_pressed():
	$traits_popup.open()


func _on_select_char_popup_hide():
	# wait modal persist_data
	yield(get_tree(), 'idle_frame')
	_update_buttons()



func _on_select_map_popup_hide():
	# wait modal persist_data
	yield(get_tree(), 'idle_frame')
	_update_buttons()


func _on_backpack_edit_popup_hide():
	# wait modal persist_data
	yield(get_tree(), 'idle_frame')
	_update_buttons()


func _on_traits_popup_popup_hide():
	# wait modal persist_data
	yield(get_tree(), 'idle_frame')
	_update_buttons()


func _on_new_game_popup_hide():
	Global.opened_popups_remove(self)


func _on_play_button_pressed():
	Global.session.current_char_id = Persistent.get_data('selected_char_id')
	Global.session.current_map_id = Persistent.get_data('selected_map_id')
	Global.session.current_deck_id = Persistent.deck_get_selected_id_from_char(Global.session.current_char_id) 

	if Global.session.current_char_id == null || !Global.chars_scenes.has(Global.session.current_char_id):
		return Global.add_toast_error("select a character")
	if Global.session.current_map_id == null || !Global.maps_scenes.has(Global.session.current_map_id):
		return Global.add_toast_error("select a map")
	if Global.session.current_deck_id == null || Persistent.get_deck(Global.session.current_deck_id) == null:
		return Global.add_toast_error("select a deck for current char")

	if Global.is_plataform_crazygames():
		var crazygames_sdk = Global.load_crazygames_sdk()
		return crazygames_sdk.play()

	get_tree().change_scene_to(Global.main_scene)


func _on_language_changed():
	char_label.set('custom_fonts/font', Global.get_font(12))
	map_label.set('custom_fonts/font', Global.get_font(12))
	backpack_label.set('custom_fonts/font', Global.get_font(12)) 
	traits_label.set('custom_fonts/font', Global.get_font(12)) 


func _on_back_button_pressed():
	hide()


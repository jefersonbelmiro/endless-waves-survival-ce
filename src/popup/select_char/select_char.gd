extends Popup

export var control_bg_color = Color("#281828")
export var text_color = Color("#acaaaa")

var button_scene = preload("res://src/popup/select_char/components/button/char_button.tscn")
var selected_main_card
var selected_char_id
var focus_char_data
var card_edit_popup

var _default_config = {
	actions_height = 20,
	container_magin_bottom = -10,
	selected_actions_size = Vector2(20, 20),
	char_button_size = Vector2(40, 40),
	char_button_font = 8,
	description_font = 8,
}

var _mobile_config = {
	actions_height = 32,
	container_magin_bottom = -4,
	selected_actions_size = Vector2(32, 32),
	char_button_size = Vector2(60, 60),
	char_button_font = 16,
	description_font = 12,
}

var _config = _default_config

onready var chars_controls = $container/content/chars/grid
onready var char_sprite = $container/content/selected/content/header/icon_container/sprite
onready var char_label = $container/content/selected/content/header/label_container/label
onready var char_description = $container/content/selected/content/scroll_container/margin_container/content/description_container/label
onready var main_card_button = $"%main_card_button"
onready var deck_button = $"%deck_button"


func _ready():
	if Global.is_mobile():
		_config = _mobile_config
		$container/actions_hint.hide()

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")
	
	Global.theme_bg($bg)
	Global.theme_panel_bg($container/content/chars/bg)
	Global.theme_panel_border($container/content/chars/bg_border)
	Global.theme_panel_bg($container/content/selected/bg)
	Global.theme_panel_border($container/content/selected/bg_border)

	chars_controls.item_size = _config.char_button_size.x
	$container.margin_bottom = _config.container_magin_bottom
	$container/actions.rect_min_size.y = _config.actions_height
	$container/actions/done_button.rect_min_size.y = _config.actions_height
	main_card_button.rect_min_size = _config.selected_actions_size
	deck_button.rect_min_size = _config.selected_actions_size


func open():
	Global.opened_popups_add(self)
	popup()

	if selected_char_id == null:
		selected_char_id = Persistent.get_data('selected_char_id')

	chars_controls.clear()

	var chars = Entities.get_chars_data()
	
	for index in chars.size():
		var char_data = chars[index]
		var node = button_scene.instance()
		node.toggle_mode = true
		node.name = char_data.id
		node.icon_texture = Global.chars_icons[char_data.id]
		node.text_label = char_data.label
		node.rect_min_size = _config.char_button_size
		node.font_size = _config.char_button_font
		node.connect("pressed", self, "_on_char_pressed", [char_data.id])
		node.connect("focus_entered", self, "_on_char_focus_entered", [char_data])
		chars_controls.add_child(node)

		if char_data.id == selected_char_id:
			_on_char_focus_entered(char_data)

	# @FIXME workaround to ScrollContainer follow_focus
	# wait popup to grab focus
	yield(get_tree(), 'idle_frame')
	chars_controls.get_node_or_null(selected_char_id).pressed = true
	chars_controls.get_node_or_null(selected_char_id).grab_focus()


func _on_char_pressed(char_id):
	if char_id != selected_char_id:
		Persistent.set_data('selected_char_id', char_id)
		Persistent.save_data()
	selected_char_id = char_id
	for index in chars_controls.get_child_count():
		var node = chars_controls.get_child(index)
		node.pressed = char_id == node.name
	if !InputSource.mouse && !Global.is_mobile():
		main_card_button.grab_focus()


func _on_char_focus_entered(char_data):
	focus_char_data = char_data
	char_sprite.frames = Global.chars_spriteframes.get(char_data.id)
	char_sprite.frame = 0
	char_sprite.play("idle")
	char_label.text = char_data.label

	char_description.bbcode_text = "[color=grey]%s[/color]" % [char_data.format_stats()]

	var deck = Persistent.deck_get_selected_from_char(char_data.id)
	if !deck:
		return
	deck_button.hint_tooltip = deck.label

	if selected_main_card == null || selected_main_card.id != char_data.main_card:
		selected_main_card = Entities.create_spell_data(char_data.main_card)

	CardHelper.set_deck(selected_main_card, deck)

	main_card_button.icon_texture = selected_main_card.icon
	main_card_button.hint_tooltip = selected_main_card.label


func _on_done_button_pressed():
	hide()


func _on_select_char_popup_hide():
	Global.opened_popups_remove(self)


func _on_main_card_button_pressed():
	$card_info_popup.open(selected_main_card)


func _on_language_changed():
	char_description.set('custom_fonts/normal_font', Global.get_font(_config.description_font))


func _on_deck_button_pressed():
	$select_deck_popup.open(focus_char_data.id)


func _on_select_deck_popup_hide():
	# wait data to be persisted
	yield(get_tree(), 'idle_frame')
	_on_char_focus_entered(focus_char_data)


func _on_card_info_popup_upgrades_button_pressed(card_data):
	if !card_edit_popup:
		card_edit_popup = Global.card_edit_popup_scene.instance()
		add_child(card_edit_popup)
	
	var deck = Persistent.deck_get_selected_from_char(focus_char_data.id)
	var coins = Persistent.get_coins()
	card_edit_popup.open(card_data, deck, coins, false)
	

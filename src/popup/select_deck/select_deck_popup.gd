extends Popup

var button_scene = preload("res://src/popup/select_deck/components/button/deck_button.tscn")
var persist_data = false
var focus_deck_id
var selected_deck_id
var selected_char_id
var decks = {}

var _default_config = {
	actions_height = 20,
	container_magin_bottom = -10,
	selected_actions_size = Vector2(20, 20),
	selected_grid_item_size = Vector2(20, 20),
	deck_button_size = Vector2(40, 40),
	deck_button_font = 8,
}

var _mobile_config = {
	actions_height = 32,
	container_magin_bottom = -4,
	selected_actions_size = Vector2(32, 32),
	selected_grid_item_size = Vector2(32, 32),
	deck_button_size = Vector2(60, 60),
	deck_button_font = 12,
}

var _config = _default_config

onready var decks_controls = $container/content/decks/grid
onready var selected_deck_grid = $container/content/selected/content/grid
onready var selected_deck_label = $container/content/selected/content/header/label_container/label
onready var edit_button = $container/content/selected/content/actions_container/edit_button
onready var remove_button = $container/content/selected/content/actions_container/remove_button
onready var deck_edit_popup = $deck_edit_popup
onready var card_info_popup = $card_info_popup
onready var card_edit_popup = $card_edit_popup
onready var meta_bar = $meta_bar

func _ready():
	if Global.is_mobile():
		_config = _mobile_config
		$container/actions_hint.hide()

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")
	
	Global.theme_bg($bg)
	Global.theme_panel_bg($container/content/decks/bg)
	Global.theme_panel_border($container/content/decks/bg_border)
	Global.theme_panel_bg($container/content/selected/bg)
	Global.theme_panel_border($container/content/selected/bg_border)

	meta_bar.margin_left = $container.margin_left
	meta_bar.margin_right = $container.margin_right
	meta_bar.margin_top = 14

	decks_controls.item_size = _config.deck_button_size.x
	selected_deck_grid.item_size = _config.selected_grid_item_size.x

	$container.margin_bottom = _config.container_magin_bottom
	$container/actions.rect_min_size.y = _config.actions_height
	$container/actions/new_button.rect_min_size.y  = _config.actions_height
	$container/actions/done_button.rect_min_size.y = _config.actions_height
	edit_button.rect_min_size = _config.selected_actions_size
	remove_button.rect_min_size = _config.selected_actions_size
	

func open(selected_char_id_):
	Global.opened_popups_add(self)
	popup()
	selected_char_id = selected_char_id_
	if !selected_char_id:
		selected_char_id = Persistent.get_data('selected_char_id')

	var selected_deck = Persistent.get_data('selected_deck') 
	selected_deck_id = selected_deck[selected_char_id]
	focus_deck_id = selected_deck_id

	decks = Persistent.get_decks_from_char(selected_char_id)

	_update_list()


func _on_deck_button_pressed(id: String):
	if !persist_data && id != selected_deck_id:
		persist_data = true
	selected_deck_id = id
	for child_index in decks_controls.get_child_count():
		var deck_button = decks_controls.get_child(child_index)
		deck_button.pressed = deck_button.name == id
	if !InputSource.mouse && !Global.is_mobile():
		edit_button.grab_focus()


func _on_edit_button_pressed():
	deck_edit_popup.open(selected_char_id, focus_deck_id)


func _on_remove_button_pressed():
	# @FIXME wait pressed animation
	yield(get_tree().create_timer(0.15), 'timeout')
	var deck = Persistent.get_deck(focus_deck_id)
	var message = tr("DELETE_DECK_CONFIRM").format({ label = tr(deck.label) })
	Global.add_confirm(message).connect("confirmed", self, "_on_remove_deck")


func _on_remove_deck():
	if decks.size() <= 1:
		return

	persist_data = true

	var decks_keys = decks.keys()
	decks_keys.sort_custom(self, "_on_sort_decks_keys")
	var selected_deck_idx = decks_keys.find(selected_deck_id)
	var focus_deck_idx = decks_keys.find(focus_deck_id)

	# restore coins
	var deck_coins = CardHelper.get_deck_cost(Persistent.get_deck(focus_deck_id) )
	if deck_coins:
		var coins = Persistent.get_coins() + deck_coins
		meta_bar.set_coins(coins)
		Persistent.set_data('meta.coins', coins)
		Persistent.save_data()

	# remove
	decks.erase(focus_deck_id)
	Persistent.get_decks().erase(focus_deck_id)
	decks_keys = decks.keys()

	# shift selected
	if selected_deck_idx >= decks.size():
		selected_deck_idx -= 1
		if selected_deck_idx < 0:
			selected_deck_idx = 0
	selected_deck_id = decks_keys[selected_deck_idx]

	# shift focus
	if focus_deck_idx >= decks.size():
		focus_deck_idx -= 1
		if focus_deck_idx < 0:
			focus_deck_idx = 0
	focus_deck_id = decks_keys[focus_deck_idx]

	_update_list()


func _on_sort_decks_keys(a, b):
	return int(a) < int(b)


func _on_done_button_pressed():
	hide()


func _on_new_button_pressed():
	deck_edit_popup.open(selected_char_id)


func _update_list():
	decks_controls.clear()

	for id in decks.keys():
		var deck = decks[id]
		var deck_button = button_scene.instance()
		deck_button.name = id
		deck_button.toggle_mode = true
		deck_button.text_label = deck.label
		deck_button.pressed = id == selected_deck_id
		deck_button.rect_min_size = _config.deck_button_size
		deck_button.font_size = _config.deck_button_font
		deck_button.connect("pressed", self, "_on_deck_button_pressed", [id])
		deck_button.connect("focus_entered", self, "_on_deck_focus_entered", [id])
		decks_controls.add_child(deck_button)

		if id == focus_deck_id:
			_on_deck_focus_entered(id)

	# @FIXME workaround to ScrollContainer follow_focus
	# wait popup to grab focus
	get_tree().create_timer(0.1, false).connect("timeout", self, "_on_update_list_update_focus")


func _on_update_list_update_focus():
	var button = decks_controls.get_node_or_null(focus_deck_id)
	if button:
		button.grab_focus()


func _on_deck_focus_entered(deck_id: String):
	focus_deck_id = deck_id

	var deck = Persistent.get_deck(deck_id)
	
	selected_deck_label.text = deck.label
	selected_deck_grid.clear()

	var cards = []
	for card_id in deck.cards.keys():
		var card_data = Entities.create_spell_data(card_id) 
		CardHelper.set_deck(card_data, deck)
		cards.append(card_data)
	cards.sort_custom(Entities, "_sort_spell_handler")

	for index in cards.size():
		selected_deck_grid.add_child(_create_deck_icon(cards[index]))

	remove_button.disabled = decks.size() <= 1


func _create_deck_icon(data):
	var node = Global.deck_card_button_scene.instance()
	node.cast_type = data.cast_type
	node.name = data.id
	node.icon_texture = data.icon
	node.rect_min_size = _config.selected_grid_item_size
	node.hint_tooltip = data.label
	node.connect("pressed", self, "_on_deck_icon_pressed", [data])
	return node


func _on_deck_icon_pressed(data):
	$card_info_popup.open(data)


func _on_select_deck_popup_hide():
	Global.opened_popups_remove(self)
	if persist_data:
		var selected_deck = Persistent.get_data('selected_deck') 
		selected_deck[selected_char_id] = selected_deck_id
		Persistent.save_data()


func _on_deck_edit_popup_edited(id, is_new):
	if is_new:
		persist_data = true
		selected_deck_id = id
		focus_deck_id = id
	decks = Persistent.get_decks_from_char(selected_char_id)
	meta_bar.set_coins(Persistent.get_coins())
	_update_list()

	
func _on_language_changed():
	selected_deck_label.set('custom_fonts/font', Global.get_font(12))


func _on_card_info_popup_upgrades_button_pressed(card_data):
	var deck = Persistent.get_deck(focus_deck_id)
	var coins = Persistent.get_coins()
	card_edit_popup.open(card_data, deck, coins)


func _on_card_edit_popup_hide():
	if !card_edit_popup.persist:
		return
	var coins = card_edit_popup.coins
	var deck = Persistent.get_deck(focus_deck_id)
	deck.cards[card_edit_popup.card.id] = card_edit_popup.deck_data

	meta_bar.set_coins(coins)
	Persistent.set_data('meta.coins', coins)
	Persistent.save_data()

	var card_data = card_edit_popup.card
	CardHelper.set_deck(card_data, deck)
	card_info_popup.update_texts(card_data)
	

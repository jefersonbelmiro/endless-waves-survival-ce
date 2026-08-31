extends Popup

signal edited(id, is_new)

var deck
var deck_id
var focus_card
var coins: int
var card_spend = {}
var cards = {}

var _default_config = {
	grid_item_size = 20,
	current_container_width = 130,
	actions_height = 20,
	container_magin_bottom = -10,
	selected_actions_size = Vector2(20, 20),
	selected_label_font = 12,
	selected_description_font = 8,
	selected_width = 120,
}

var _mobile_config = {
	grid_item_size = 40,
	current_container_width = 150,
	actions_height = 32,
	container_magin_bottom = -4,
	selected_actions_size = Vector2(32, 32),
	selected_label_font = 16,
	selected_description_font = 10,
	selected_width = 160,
}

var _config = _default_config

onready var meta_bar = $meta_bar
onready var label_input = $title/line_edit
onready var content_container = $container/content
onready var current_container = $container/content/current/grid
onready var avaliable_container = $container/content/avaliable/grid
onready var selected_icon = $container/content/selected/content/header/icon
onready var selected_label = $container/content/selected/content/header/label_container/label
onready var selected_description = $container/content/selected/content/description_container/description
onready var actions_container = $container/content/selected/content/actions_container
onready var add_button = $container/content/selected/content/actions_container/add_button
onready var remove_button = $container/content/selected/content/actions_container/remove_button
onready var card_edit_button = $container/content/selected/content/actions_container/edit_button
onready var card_edit_popup = $card_edit_popup

func _ready():
	if Global.is_mobile():
		_config = _mobile_config
		$container/actions_hint.hide()

	$container/content/current.rect_min_size.x = _config.current_container_width
	current_container.item_size = _config.grid_item_size
	avaliable_container.item_size = _config.grid_item_size
	$container.margin_bottom = _config.container_magin_bottom
	$container/actions.rect_min_size.y = _config.actions_height
	$container/actions/cancel_button.rect_min_size.y  = _config.actions_height
	$container/actions/done_button.rect_min_size.y = _config.actions_height

	$container/content/selected.rect_min_size.x = _config.selected_width
	add_button.rect_min_size = _config.selected_actions_size
	remove_button.rect_min_size = _config.selected_actions_size
	card_edit_button.rect_min_size = _config.selected_actions_size
	
	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")
	
	Global.theme_bg($bg)
	Global.theme_panel_bg($container/content/current/bg)
	Global.theme_panel_border($container/content/current/bg_border)
	Global.theme_panel_bg($container/content/avaliable/bg)
	Global.theme_panel_border($container/content/avaliable/bg_border)
	Global.theme_panel_bg($container/content/selected/bg)
	Global.theme_panel_border($container/content/selected/bg_border)


func open(selected_char_id, id = null):
	var decks = Persistent.get_decks()
	deck_id = id
	
	if id != null:
		deck = decks[id].duplicate(true)
	else:
		deck = {
			id = str(Persistent.get_last_deck_id() + 1),
			char_id = selected_char_id,
			label = "deck #%s" % [Persistent.get_last_deck_id() + 1],
			cards = {}
		}
	
	card_spend = {}
	coins = Persistent.get_coins()
	meta_bar.set_coins(coins)
	Global.opened_popups_add(self)
	popup()

	avaliable_container.clear()
	current_container.clear()

	var spells = Entities.get_spells_data()
	for index in spells.size():
		var data = spells[index].duplicate()
		if 'visible' in data:
			if typeof(data.visible) == TYPE_STRING && data.visible == 'editor' && !OS.is_debug_build():
				continue
			elif !data.visible:
				continue
		
		if deck.cards.has(data.id):
			CardHelper.set_deck(data, deck)
			current_container.add_child(_create_button(data))
		else:
			CardHelper.set_deck(data, null)
			avaliable_container.add_child(_create_button(data))
		cards[data.id] = data

	label_input.text = tr(deck.label)
	label_input.focus_mode = Control.FOCUS_ALL
	if avaliable_container.get_child_count():
		avaliable_container.get_child(0).grab_focus()
	elif current_container.get_child_count():
		 current_container.get_child(0).grab_focus()


func _shadown_animation(data, node, ref_node):
	if !is_instance_valid(ref_node) || ref_node.modulate.a == 0:
		return
	node.modulate.a = 0
	ref_node.modulate.a = 0
	var ref_node_global_position = ref_node.get_global_position()
	var container = node.get_parent()

	# delay to container adjust child
	yield(get_tree().create_timer(0.1, false), 'timeout')
	if !is_instance_valid(node):
		return
	var node_global_position = node.get_global_position()
	var shadow = _create_shadow_button(data)
	add_child(shadow)

	var distance = node_global_position - ref_node_global_position 
	var jump_position = (ref_node_global_position + distance.normalized() * distance.length() * 0.2 ) + Vector2(0, -50)
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(self, '_update_shadow_position', 0.0, 1.0, 0.4, [shadow, ref_node_global_position, jump_position, node_global_position])
	yield(tween, 'finished')

	# node instance can change, on multipe _update_*_grid()
	node = container.get_node_or_null(data.id)
	if is_instance_valid(node):
		node.modulate.a = 1
	shadow.queue_free()


# use quadratic bezier
# https://docs.godotengine.org/en/3.6/tutorials/math/beziers_and_curves.html
func _update_shadow_position(weight: float, shadow_node, start_position, jump_position, end_position):
	var q0 = start_position.linear_interpolate(jump_position, weight)
	var q1 = jump_position.linear_interpolate(end_position, weight)
	var position = q0.linear_interpolate(q1, weight)
	shadow_node.rect_global_position = position


func _create_shadow_button(data):
	var button = Global.deck_card_button_scene.instance()
	button.icon_texture = data.icon
	button.rect_min_size = Vector2(_config.grid_item_size, _config.grid_item_size)
	return button


func _create_button(data):
	var button = Global.deck_card_button_scene.instance()
	button.cast_type = data.cast_type
	button.icon_texture = data.icon
	button.rect_min_size = Vector2(_config.grid_item_size, _config.grid_item_size)
	button.name = data.id
	button.hint_tooltip = data.label
	button.connect("pressed", self, "_on_card_pressed")
	button.connect("gui_input", self, "_on_card_gui_input", [data, button])
	button.connect("focus_entered", self, "_on_card_focus_entered", [data])
	return button


func _on_card_pressed():
	if !InputSource.mouse && !Global.is_mobile():
		_focus_first_action()


func _focus_first_action():
	for index in actions_container.get_child_count():
		var node =  actions_container.get_child(index)
		if node.visible:
			node.grab_focus()
			break


func _on_card_gui_input(event, data, node):
	var is_avaliable = String(node.get_path()).begins_with(avaliable_container.get_path())
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			if is_avaliable:
				_add_card(data)
				SFX.add_button_pressed()
			else:
				_remove_card(data)
				SFX.add_button_pressed()


func _on_card_focus_entered(data):
	_on_focus_card(data)


func _add_card(data):
	if !deck.cards.has(data.id):
		deck.cards[data.id] = CardHelper.create_deck_upgrades_data(data)
		_update_current_grid()
		var button = current_container.get_node_or_null(data.id)
		var ref_node = avaliable_container.get_node_or_null(data.id)
		_shadown_animation(data, button, ref_node)
			
		# @TODO add timer to update list and reset every add/remove
		yield(get_tree().create_timer(0.4, false), 'timeout')
		_update_avaliable_grid()
		if data == focus_card:
			button = current_container.get_node_or_null(data.id)
			if is_instance_valid(button):
				button.grab_focus()

	_on_focus_card(data)


func _remove_card(data):
	if deck.cards.has(data.id):
		# restore default ugprades data
		CardHelper.set_deck(data, null)

		if card_spend.has(data.id):
			coins += card_spend[data.id]
			meta_bar.set_coins(coins)
			card_spend[data.id] = 0

		deck.cards.erase(data.id)
		_update_avaliable_grid()
		var button = avaliable_container.get_node_or_null(data.id)
		var ref_node = current_container.get_node_or_null(data.id)
		_shadown_animation(data, button, ref_node)

		# @TODO add timer to update list and reset every add/remove
		yield(get_tree().create_timer(0.4, false), 'timeout')
		_update_current_grid()
		if focus_card == data:
			button = avaliable_container.get_node_or_null(data.id)
			if is_instance_valid(button):
				button.grab_focus()

	_on_focus_card(data)


func _update_avaliable_grid():
	avaliable_container.clear()
	for card_id in cards.keys():
		var data = cards[card_id]
		if !deck.cards.has(data.id):
			CardHelper.set_deck(data, null)
			var button = _create_button(data)
			avaliable_container.add_child(button)


func _update_current_grid():
	current_container.clear()
	for card_id in cards.keys():
		var data = cards[card_id]
		if deck.cards.has(data.id):
			CardHelper.set_deck(data, deck)
			var button = _create_button(data)
			current_container.add_child(button)


func _on_focus_card(data):
	focus_card = data
	add_button.hide()
	remove_button.hide()
	card_edit_button.hide()
	
	if deck.cards.has(data.id):
		remove_button.show()
		if 'upgrades_data' in data:
			card_edit_button.show()
	else:
		add_button.show()
	
	selected_icon.texture = data.icon
	selected_label.text = data.label

	var description = data.format_description()
	if 'require_description' in data:
		description += "\n\n%s" % [tr(data.require_description)]
	if description:
		description += "\n\n"
	description += "%s" % [data.format_info()]

	var upgrades_size = data.format_upgrades_size()
	if upgrades_size:
		description += "\n%s\n%s" % [upgrades_size, data.format_details()]
	else:
		description += "\n%s" % [data.format_details()]

	selected_description.bbcode_text = description
	

func _on_done_button_pressed():
	if !deck.label:
		return Global.add_toast_error(tr("DECK_NAME_REQUIRED"))

	if deck.cards.size() == 0:
		return Global.add_toast_error(tr("DECK_CARDS_REQUIRED"))
	
	var decks = Persistent.get_decks()
	var is_new = deck_id == null
	decks[deck.id] = deck

	if is_new:
		Persistent.set_last_deck_id(deck.id)
	Persistent.set_data('meta.coins', coins)
	Persistent.set_data('meta.decks', decks)
	Persistent.save_data()

	emit_signal("edited", deck.id, is_new)

	hide()


func _on_cancel_button_pressed():
	hide()


func _on_add_button_pressed():
	var result = _add_card(focus_card)
	if result:
		yield(result, 'completed')
	_focus_first_action()
	

func _on_remove_button_pressed():
	var result = _remove_card(focus_card)
	if result:
		yield(result, 'completed')
	_focus_first_action()


func _on_line_edit_text_changed(new_text):
	deck.label = new_text


func _on_deck_edit_popup_popup_hide():
	Global.opened_popups_remove(self)
	label_input.focus_mode = Control.FOCUS_NONE


func _on_language_changed():
	selected_label.set('custom_fonts/font', Global.get_font(_config.selected_label_font))
	selected_description.set('custom_fonts/normal_font', Global.get_font(_config.selected_description_font))


func _on_line_edit_focus_entered():
	content_container.disabled = true


func _on_line_edit_focus_exited():
	content_container.disabled = false


func _on_edit_button_pressed():
	CardHelper.set_deck(focus_card, deck)
	if !card_spend.has(focus_card.id):
		card_spend[focus_card.id] = 0
	card_edit_popup.open(focus_card, deck, coins)


func _on_card_edit_popup_hide():
	if !card_edit_popup.persist:
		return
	card_spend[focus_card.id] += coins - card_edit_popup.coins 
	coins = card_edit_popup.coins
	deck.cards[focus_card.id] = card_edit_popup.deck_data
	meta_bar.set_coins(coins)
	CardHelper.set_deck(focus_card, deck)
	_on_focus_card(focus_card)


extends Popup

signal action_pause_pressed

var button_scene = preload("res://src/popup/upgrade/button/upgrade_button.tscn")

var all = {}
var reroll_cost = 10
var discard_cost = 5
var lock_cost = 20
var cards_draw_size = 3

# flag to prevent double button pressed issue
# button has delay to wait caster created to next roll detect current player cards 
var _card_pressed = false

var _discard_pressed = false
var _lock_pressed = false
var _current_deck
var _avaliable_cards = []
var _lock_cards = []
var _current_cards = {}

var _default_config = {
	container_margin_top = 16
}

var _mobile_config = {
	container_margin_top = 2
}

var _config = _default_config

onready var container = $"%container"
onready var buttons_container = $"%buttons_container"
onready var open_timer = $open_timer
onready var reroll_button = $"%reroll_button"
onready var discard_button = $"%discard_button"
onready var lock_button = $"%lock_button"

func _ready():
	if Global.is_mobile():
		_config = _mobile_config
	
	randomize()
	Global.connect('player_level_changed', self, '_on_player_level_changed')

	reroll_button.cost = reroll_cost
	discard_button.cost = discard_cost
	lock_button.cost = lock_cost
	_current_deck = Persistent.get_deck(Global.session.current_deck_id)
	for card_id in _current_deck.cards.keys():
		var card_data = Entities.create_spell_data(card_id)
		CardHelper.set_deck(card_data, _current_deck)
		all[card_id] = card_data
		

	if Global.is_mobile():
		container.set_anchors_and_margins_preset(PRESET_WIDE)
		buttons_container.set_anchors_and_margins_preset(PRESET_WIDE) 
		container.margin_bottom = -3

	container.margin_top = _config.container_margin_top


func _input(event: InputEvent) -> void:
	if !visible:
		return
	if event.is_action_pressed("pause"):
		emit_signal("action_pause_pressed")


func open():
	if Global.player.upgrade_points <= 0:
		return
	Global.opened_popups_add(self, { popup_tween = false })
	popup()
	_roll()


func _on_open_timer_timeout():
	if !Global.player.is_alive():
		return
	if Global.player.upgrade_points <= 0:
		return
	Global.set_paused(true)
	open()


func _roll():
	Global.node_remove_children(buttons_container)

	_current_cards = {}
	_update_avaliable_cards()

	_update_actions_state()
	
	if !_create_cards(cards_draw_size):
		hide()
		return

	if buttons_container.get_child_count():
		buttons_container.get_child(0).grab_focus()
		
	_update_buttons_positions()
	_update_card_button_state()
	_add_sfx_popup()


func _add_sfx_popup():
	get_tree().create_timer(0.2).connect("timeout", SFX, "add_popup")


func _update_buttons_positions():
	var width = buttons_container.rect_size.x
	var size = buttons_container.get_child_count() 
	var item_width = buttons_container.get_child(0).rect_size.x
	var margin = 10
	var margin_left = width/2 - item_width * size / 2 
	if size > 1:
		margin_left -= ((size -1) * margin / 2.0)

	for index in size:
		var button = buttons_container.get_child(index)
		button.margin_top = 0
		button.margin_right = 0
		button.margin_bottom = 0
		button.margin_left = 0
		if index - 1 > 0:
			button.focus_neighbour_left = buttons_container.get_child(index - 1).get_path()
		if index + 1 < size - 1:
			button.focus_neighbour_right = buttons_container.get_child(index + 1).get_path()
		button.rect_position.x = margin_left + (item_width * index) + (margin * index)


func _discard(data):
	var current_button
	var index
	
	if _current_cards.has(data.id):
		current_button = _current_cards.get(data.id).node
		index = _current_cards.get(data.id).index

	_current_cards.erase(data.id)
	_update_avaliable_cards()

	if !current_button:
		return false

	var created = _create_cards(1, index)
	var focus_control = get_focus_owner()
	var current_position = current_button.rect_position
	if current_button != focus_control:
		focus_control = null
	current_button.queue_free()
	if created:
		_add_sfx_popup()
		var last_added = buttons_container.get_child(buttons_container.get_child_count() - 1)
		last_added.name = last_added.data.id
		last_added.rect_position = current_position
		if focus_control:
			last_added.grab_focus()
	_discard_pressed = false
	return created


func _create_card(data, offset = 0):
	# ignore repeated
	if _current_cards.has(data.id):
		return false
	if Global.player.spells.has(data.id):
		data = Global.player.get_card_data(data.id)
		if !data.has_upgrade():
			return false
	elif data.cast_type != Global.SKILL_CAST_TYPE.PASSIVE && !Global.hud_spell_slots.can_add(data):
		return false
	if 'upgrades_data' in data && data.level > 0:
		var card_avaliable_upgrades = data.get_avaliable_upgrades()
		var upgrade_size = randi() % card_avaliable_upgrades.size()
		card_avaliable_upgrades.shuffle()
		var card_next_upgrades = card_avaliable_upgrades.slice(0, upgrade_size)
		data.set_next_upgrades(card_next_upgrades)

	_create_button(data)
	_current_cards[data.id] = { index =  offset, node = buttons_container.get_child(buttons_container.get_child_count() - 1) }
	return true


func _create_cards(size: int, offset = 0):
	var created = []
	var expected_size = min(_avaliable_cards.size(), size)
	var current_index = _avaliable_cards.size() - 1

	if expected_size == 0:
		return false

	for data_id in _lock_cards:
		if !_create_card(all[data_id], offset):
			continue
		created.append(data_id)
		offset += 1
		if created.size() >= expected_size:
			break

	while created.size() < expected_size && current_index >= 0:
		var data
		if expected_size <= size:
			data = _avaliable_cards[current_index]
			current_index -= 1
		else:
			data = _avaliable_cards[randi() % _avaliable_cards.size()]

		if !_create_card(data, offset):
			continue
		created.append(data.id)
		offset += 1

	return created.size() > 0


func _check_card_slots():
	for card_id in _current_cards.keys():
		var _current_card_data = _current_cards.get(card_id)
		var data = all[card_id]
		if !Global.player.spells.has(data.id) && data.cast_type != Global.SKILL_CAST_TYPE.PASSIVE && !Global.hud_spell_slots.can_add(data):
			_discard(data)
		elif _current_card_data.node.get_index() != _current_card_data.index:
			buttons_container.move_child(_current_card_data.node, _current_card_data.index)


func _update_card_button_state():
	for index in buttons_container.get_child_count():
		var node = buttons_container.get_child(index)
		node.mode = node.MODES.UPGRADING
		if _lock_pressed:
			node.mode = node.MODES.LOCKING
		elif _discard_pressed:
			node.mode = node.MODES.DISCARDING
		node.lock = _lock_pressed || _lock_cards.has(node.data.id)
		node.discard = _discard_pressed
		node.update_focus()


func _update_actions_state():
	reroll_button.disabled = Global.player.coins < reroll_cost
	discard_button.disabled = Global.player.coins < discard_cost
	if _current_cards.size() >= _avaliable_cards.size():
		lock_button.disabled = true
		return
	lock_button.disabled = Global.player.coins < lock_cost || _avaliable_cards.size() <= cards_draw_size 


func _update_avaliable_cards():
	_avaliable_cards = []
	for data_id in all.keys():
		var data = all[data_id]
		if Global.player.spells.has(data.id):
			data = Global.player.get_card_data(data.id)
			if !data.has_upgrade():
				continue
		elif data.cast_type != Global.SKILL_CAST_TYPE.PASSIVE && !Global.hud_spell_slots.can_add(data):
			continue
		_avaliable_cards.append(data)
	_avaliable_cards.shuffle()


func _create_button(data):
	var button = button_scene.instance()
	button.data = data
	button.lock = _lock_pressed || _lock_cards.has(data.id)
	button.connect("pressed", self, "_on_card_button_pressed", [data])
	buttons_container.add_child(button)


func _on_upgrade_popup_popup_hide():
	Global.opened_popups_remove(self)


func _on_player_level_changed():
	if !Settings.get_auto_levelup():
		return
	open_timer.start()


func _on_card_button_pressed(data):
	# prevent double button pressed issue
	if _card_pressed:
		return
	if _discard_pressed: 
		_lock_cards.erase(data.id)
		_discard(data)
		_check_card_slots()
	elif _lock_pressed:
		_lock(data)
	else:
		Global.player.upgrade_points -= 1
		Global.player.add_card(data.id)
		Global.emit_signal('player_upgrade_points_changed')
		if Global.player.upgrade_points <= 0:
			hide()
		else:
			_card_pressed = true
			# wait caster created
			# get_tree().create_timer(0.1).connect('timeout', self, "_on_card_pressed_delay_timeout", [data])
			_on_card_pressed_delay_timeout(data)
	_update_actions_state()
	_update_card_button_state()


func _on_card_pressed_delay_timeout(data):
	_card_pressed = false
	_discard(data)
	_check_card_slots()
	var updated_data = Global.player.get_card_data(data.id)
	if !updated_data.has_upgrade():
		_lock_cards.erase(data.id)


func _lock(data):
	if !_lock_cards.has(data.id):
		_lock_cards.append(data.id)
	_lock_pressed = false


func _on_reroll_button_pressed():
	Global.player.coins -= reroll_cost
	Global.emit_signal('player_coins_changed', 0)
	_roll()


func _on_discard_button_pressed():
	_discard_pressed = true
	Global.player.coins -= reroll_cost
	Global.emit_signal('player_coins_changed', 0)
	Global.add_toast(tr("SELECT_CARD_DISCARD"))

	discard_button.disabled = true
	reroll_button.disabled = true
	lock_button.disabled = true
	buttons_container.get_child(0).grab_focus()
	_update_card_button_state()


func _on_lock_button_pressed():
	_lock_pressed = true
	Global.player.coins -= lock_cost
	Global.emit_signal('player_coins_changed', 0)
	Global.add_toast(tr("SELECT_CARD_LOCK"))

	discard_button.disabled = true
	reroll_button.disabled = true
	lock_button.disabled = true
	buttons_container.get_child(0).grab_focus()
	_update_card_button_state()


func _on_buttons_container_child_exiting_tree(_node:Node):
	if !buttons_container.get_child_count(): 
		hide()
	else:
		_update_buttons_positions()
	

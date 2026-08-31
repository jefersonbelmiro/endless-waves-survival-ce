extends Popup

const button_scene = preload("res://src/popup/chest/button/chest_button.tscn")

var _default_config = {
	container_margin_top = 36
}

var _mobile_config = {
	container_margin_top = 26
}

var _config = _default_config

var all_cards = {}
var all_consumables = {}
var level = 1

onready var container = $"%container"
onready var buttons_container = $"%buttons_container"
onready var sprite_container = $sprite_container
onready var sprite = $sprite_container/animated_sprite
onready var openned_sfx = $openned_sfx
onready var open_sfx = $open_sfx

func _ready():
	if Global.is_mobile():
		_config = _mobile_config
	randomize()
	
	Global.connect('chest_collected', self, '_on_chest_collected')

	container.margin_top = _config.container_margin_top
	buttons_container.set_anchors_and_margins_preset(PRESET_WIDE)

	var _current_deck = Persistent.get_deck(Global.session.current_deck_id)
	for card_id in _current_deck.cards.keys():
		var card_data = Entities.create_spell_data(card_id)
		CardHelper.set_deck(card_data, _current_deck)
		all_cards[card_id] = card_data

	var consumables = Entities.get_consumables_data().duplicate(true)
	for index in consumables.size():
		var consumable = consumables[index]
		all_consumables[consumable.id] = consumable


func open():
	Global.set_paused(true)
	Global.opened_popups_add(self, { popup_tween = false })
	popup()
	
	Global.node_remove_children(buttons_container)
	sprite.position = Vector2(32, 32)
	sprite.rotation_degrees = 0
	sprite.scale = Vector2(1, 1)
	sprite.frame = 0
	sprite.stop()
	sprite_container.show()
	sprite_container.rect_pivot_offset = sprite_container.rect_size/2
	sprite_container.rect_scale = Vector2(0.3, 0.3)

	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_container, 'rect_scale', Vector2(1.2, 1.2), 0.2)

	var shake = 2
	var shake_duration = 0.05
	var shake_count = 5
	for i in shake_count:
		# tween.tween_property(sprite, "position", sprite.position + Vector2(rand_range(-shake, shake), rand_range(-shake, shake)), shake_duration)
		tween.tween_property(sprite, "rotation_degrees", rand_range(-shake, shake), shake_duration)
		tween.tween_property(sprite, "scale", Vector2(rand_range(1.2, 1.3), rand_range(1.2, 1.3)), shake_duration)
	tween.tween_property(sprite, "rotation_degrees", 0, shake_duration * 2)

	tween.connect("finished", self, "_on_open_tween_finished", [], CONNECT_ONESHOT)
	open_sfx.play()


func _on_open_tween_finished():
	openned_sfx.play()
	sprite.play()
	sprite.connect("animation_finished", self, "_on_animated_sprite_animation_finished", [], CONNECT_ONESHOT)


func _roll():
	var types = ["card", "consumable", "experience"]
	var size = randi() % 2 + 1
	var items = []
	var cards = _get_avaliable_cards()
	var consumables = all_consumables.keys()
	var safe_it = 100

	var consumable_min_size = 1
	var consumable_max_size = 2 + level - 1
	var consumable_size = randi() % consumable_max_size + consumable_min_size

	var coin_min_size = 10 + level * 2
	var coin_max_size = 50 + level * 5
	var coin_size = int(rand_range(coin_min_size, coin_max_size) / 5) * 5

	var experience_min_size = Global.player._get_level_exp() / 5
	var experience_max_size = Global.player._get_level_exp() * 2
	var experience_size = int(rand_range(experience_min_size, experience_max_size) / 5) * 5
	var trait_chest_factor = Traits.get_chest_factor()

	while items.size() < size && safe_it > 0:
		safe_it -= 1
		var type = types[randi() % types.size()]

		if type == "experience":
			var value_size = experience_size + floor(experience_size * trait_chest_factor)
			var data = { uid = type, value = value_size, icon = Global.experiences_texture }
			items.append(data)
			types.erase(type)

		if type == 'card':
			if cards.size() == 0:
				types.erase(type)
				continue
			var data = cards[randi() % cards.size()]
			if 'upgrades_data' in data && data.level > 0:
				var card_avaliable_upgrades = data.get_avaliable_upgrades()
				var upgrade_size = randi() % card_avaliable_upgrades.size()
				upgrade_size = clamp(floor(upgrade_size + upgrade_size * trait_chest_factor), upgrade_size, card_avaliable_upgrades.size() - 1)
				card_avaliable_upgrades.shuffle()
				var card_next_upgrades = card_avaliable_upgrades.slice(0, upgrade_size)
				data.set_next_upgrades(card_next_upgrades)
			cards.erase(data)
			items.append(data)

		if type == 'consumable':
			if consumables.size() == 0:
				types.erase(type)
				continue
			var data_id = consumables[randi() % consumables.size()]
			var data = all_consumables[data_id]
			consumables.erase(data_id)
			var data_append = data.duplicate()
			data_append._size = consumable_size + floor(consumable_size * trait_chest_factor)
			items.append(data_append)

	var coin_value_size = coin_size + floor(coin_size * trait_chest_factor) 
	if Global.player.stats.collect_coin_factor:
		coin_value_size += coin_value_size * Global.player.stats.collect_coin_factor

	items.append({ uid = "coin", value = coin_value_size, icon = Global.coins_texture })

	Global.node_remove_children(buttons_container)

	for index in items.size():
		_create_button(items[index])

	buttons_container.get_child(0).grab_focus()
	_update_buttons_positions()
	Global.delay_func(SFX, "add_popup", 0.5)


func _get_avaliable_cards():
	var result = []
	for card_id in Global.player.deck.cards.keys():
		var data = all_cards[card_id]
		if Global.player.spells.has(data.id):
			data = Global.player.get_card_data(card_id) 
			if !data.has_upgrade():
				continue
		elif data.cast_type != Global.SKILL_CAST_TYPE.PASSIVE && !Global.hud_spell_slots.can_add(data):
			continue
		result.append(data)
	result.shuffle()
	return result


func _on_chest_collected(chest_level: int):
	Global.set_paused(true)
	level = chest_level
	open()
	

func _create_button(data):
	var button = button_scene.instance()
	button.data = data
	button.connect("pressed", self, "_on_button_pressed", [data])
	buttons_container.add_child(button)


func _on_button_pressed(data):
	var type = data.uid.split("_")[0]
	match type:
		"card", "spell": Global.player.add_card(data.id)
		"consumable": 
			for _index in data._size:
				Global.player.backpack.add(data.id)
			SFX.add_experience()
		"experience": 
			Global.player.add_experience(data.value)
			SFX.add_experience()
		"coin": 
			Global.player.add_coins(data.value)
			SFX.add_coin()
		_: push_error("invalid type: " + type)
	hide()
	

func _update_buttons_positions():
	var width = buttons_container.rect_size.x
	var size = buttons_container.get_child_count() 
	var item_width = buttons_container.get_child(0).rect_size.x
	var margin_left = width/2 - item_width * size / 2
	var margin = 10

	var center_position = get_viewport_rect().size * 0.5

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

		# button.rect_position.x = margin_left + (item_width * index) + (margin * index)
		var target_position = Vector2(margin_left + (item_width * index) + (margin * index), button.rect_position.y)
		button.target_position = target_position
		button.rect_position = Vector2(center_position.x - button.rect_size.x/2, button.rect_position.y)
		button.create_popup_tween()



func _on_chest_popup_hide():
	Global.opened_popups_remove(self)
	

func _on_discard_button_pressed():
	hide()


func _on_buttons_container_resized():
	if visible && buttons_container.get_child_count():
		Global.throttle_func(self, "_update_buttons_positions")


func _on_animated_sprite_animation_finished():
	Global.delay_func(sprite_container, "hide", 0.15)
	_roll()




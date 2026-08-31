extends Popup

var card
var deck
var coins: int
var selected_upgrade
var deck_data
var coin_icon = "[img=4x4]res://assets/icons/coin_padless.png[/img]"
var persist = false
var editable = true

var upgrade_icons = {
	damage = preload("res://assets/icons/upgrades/damage.png"),
	base_damage_factor = preload("res://assets/icons/upgrades/damage.png"),
	max_projectiles = preload("res://assets/icons/upgrades/max_projectiles.png"),
	damage_knockback = preload("res://assets/icons/upgrades/damage_knockback.png"),
	scale_factor = preload("res://assets/icons/upgrades/scale_factor.png"),
	bounces = preload("res://assets/icons/upgrades/bounces.png"),
	cooldown = preload("res://assets/icons/upgrades/cooldown.png"),
	damage_block = preload("res://assets/icons/upgrades/damage_block.png"),
	defense = preload("res://assets/icons/upgrades/damage_block.png"),
	projectile_speed = preload("res://assets/icons/upgrades/projectile_speed.png"), 
	move_speed = preload("res://assets/icons/upgrades/move_speed.png"),
	duration = preload("res://assets/icons/upgrades/duration.png"),
	attack_speed = preload("res://assets/icons/upgrades/attack_speed.png"),
	area = preload("res://assets/icons/upgrades/area.png"),
	spread = preload("res://assets/icons/upgrades/spread.png"),
	pass_through = preload("res://assets/icons/upgrades/pass_through.png"),
	explosion = preload("res://assets/icons/upgrades/explosion.png"),
	health_healing = preload("res://assets/icons/upgrades/healing.png"),
	max_health = preload("res://assets/icons/upgrades/max_health.png"),
}

var _default_config = {
	grid_item_size = 20,
	card_button_font = 8,
	current_container_width = 130,
	container_magin_bottom = -10,
	actions_height = 20,
	selected_width = 160,
	selected_actions_size = Vector2(20, 20),
	selected_label_font = 12,
	selected_description_font = 8,
	selected_details_font = 8,
}

var _mobile_config = {
	grid_item_size = 40,
	card_button_font = 16,
	current_container_width = 150,
	container_magin_bottom = -4,
	actions_height = 32,
	selected_width = 200,
	selected_actions_size = Vector2(32, 32),
	selected_label_font = 16,
	selected_description_font = 12,
	selected_details_font = 12,
}

var _config = _default_config

onready var title = $title
onready var meta_bar = $meta_bar
onready var content_container = $container/content
onready var avaliable_container = $container/content/avaliable/grid
onready var selected_icon = $container/content/selected/content/header/icon
onready var selected_label = $container/content/selected/content/header/label_container/label
onready var selected_description = $container/content/selected/content/description_container/description
onready var seleted_details = $container/content/selected/content/details_container/details
onready var selected_actions_container = $container/content/selected/content/actions_container
onready var visible_button = $container/content/selected/content/actions_container/visible_button
onready var upgrade_button = $container/content/selected/content/actions_container/upgrade_button
onready var downgrade_button = $container/content/selected/content/actions_container/downgrade_button
onready var unlock_button = $container/content/selected/content/actions_container/unlock_button
onready var actions_container = $container/actions
onready var cancel_button = $container/actions/cancel_button
onready var done_button = $container/actions/done_button


func _ready():
	if Global.is_mobile():
		_config = _mobile_config
		$container/actions_hint.hide()
	
	$container/content/selected.rect_min_size.x = _config.selected_width
	$container.margin_bottom = _config.container_magin_bottom
	$container/content/avaliable.rect_min_size.x = _config.current_container_width
	avaliable_container.item_size = _config.grid_item_size
	cancel_button.rect_min_size.y = _config.actions_height
	done_button.rect_min_size.y = _config.actions_height

	for index in selected_actions_container.get_child_count():
		var node = selected_actions_container.get_child(index)
		node.rect_min_size = _config.selected_actions_size

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")
	
	Global.theme_bg($bg)
	Global.theme_panel_bg($container/content/avaliable/bg)
	Global.theme_panel_border($container/content/avaliable/bg_border)
	Global.theme_panel_bg($container/content/selected/bg)
	Global.theme_panel_border($container/content/selected/bg_border)


func open(card_, deck_, coins_, editable_ = true):
	card = card_
	deck = deck_
	coins = coins_
	editable = editable_
	
	deck_data = deck.cards[card.id].duplicate(true)

	avaliable_container.clear()
	meta_bar.set_coins(coins)
	title.text = card.label

	if !editable:
		selected_actions_container.hide()
		cancel_button.text_label = "CLOSE"
		done_button.hide()
		meta_bar.hide()

	Global.opened_popups_add(self)
	popup()

	for key in card.upgrades_data.keys():
		var data = card.upgrades_data[key]
		avaliable_container.add_child(_create_button(data))

	avaliable_container.get_child(0).button.grab_focus()


func _get_icon_texture(data):
	if 'icon' in data:
		return load(data.icon)
	elif upgrade_icons.has(data.id):
		return upgrade_icons[data.id]
	else:
		return Global.icon_placeholder_texture


func _create_button(data):
	var node = Global.card_upgrade_button_scene.instance()
	var button = node.get_node("container/button")
	button.icon_texture = _get_icon_texture(data)
	button.icon_color = Color("#acaaaa") 
	node.size = Vector2(_config.grid_item_size, _config.grid_item_size)
	node.font_size = _config.card_button_font
	node.name = data.id
	button.connect("pressed", self, "_on_card_pressed")
	button.connect("focus_entered", self, "_on_card_focus_entered", [data])

	var deck_upgrade_data = deck_data[data.id]
	button.soft_disabled = !deck_upgrade_data.active || deck_upgrade_data.unlock_index < 0

	if deck_upgrade_data.active:
		node.text_label = "%s/%s" % [deck_upgrade_data.max_index + 1, data.value.size()]
	else:
		node.text_label = "%s/%s" % [0, data.value.size()]

	if deck_upgrade_data.unlock_index < 0:
		var locked_icon = Global.locked_icon_scene.instance()
		locked_icon.rect_min_size = node.size
		node.add_child(locked_icon)

	return node


func _on_card_pressed():
	if InputSource.mouse || Global.is_mobile():
		return
	if visible_button.visible: 
		visible_button.grab_focus()
	else:
		unlock_button.grab_focus()


func _on_card_focus_entered(data):
	var deck_upgrade_data = deck_data[data.id]

	unlock_button.get_node("tooltip").text = ""
	upgrade_button.get_node("tooltip").text = ""
	seleted_details.hide()

	if deck_upgrade_data.unlock_index < 0:
		unlock_button.show()
		visible_button.hide()
		upgrade_button.hide()
		downgrade_button.hide()
	else:
		unlock_button.hide()
		visible_button.show()
		upgrade_button.disabled = !deck_upgrade_data.active || deck_upgrade_data.max_index >= data.value.size() - 1
		upgrade_button.show()
		downgrade_button.disabled = !deck_upgrade_data.active || deck_upgrade_data.max_index <= 0
		downgrade_button.show()

	selected_upgrade = data
	selected_icon.texture = _get_icon_texture(data)

	selected_label.text = data.label
	
	var description = "" 
	if 'edit_description' in data:
		description = "%s\n\n" % [tr(data.edit_description).format(DataFormatter.it_data(data))]
	elif 'description' in data:
		description = "%s\n\n" % [tr(data.description).format(DataFormatter.it_data(data))]

	var public_keys = FP.safe_get(card, 'value_public_keys', null)
	var private_keys = FP.safe_get(card, 'value_private_keys', null)
	var value_format_keys = FP.safe_get(card, 'value_format_keys', {})
	var upgrade_data = {}
	for index in data.value.size():
		var upgrade = data.value[index]
		for key in upgrade.keys():
			if key == 'cost' || (public_keys != null && !public_keys.has(key)) || (private_keys != null && private_keys.has(key)): 
				continue
			if !key in upgrade_data: 
				upgrade_data[key] = []
			var value
			if value_format_keys.has(key) && 'format' in value_format_keys[key]:
				value = DataFormatter.format_handler(upgrade[key], value_format_keys[key].format)
			else:
				value = DataFormatter.format(key, upgrade)
			upgrade_data[key].append(value)

	var upgrade_id_eq_value_key = upgrade_data.size() == 1 && upgrade_data.keys()[0] == data.id
	if upgrade_id_eq_value_key:
		description += "%s:\n" % [tr("UPGRADES")]
	for key in upgrade_data.keys():
		if !upgrade_id_eq_value_key:
			var desc_key = key
			if value_format_keys.has(key) && 'tr' in value_format_keys[key]:
				desc_key = value_format_keys[key].tr
			description += "%s:\n" % [DataFormatter.format_key(desc_key)]
		var upgrade_values = PoolStringArray()
		for index in upgrade_data[key].size():
			var value = upgrade_data[key][index]
			if !deck_upgrade_data.active || index > deck_upgrade_data.max_index:
				upgrade_values.append("[color=grey]%s[/color]" % [value])
			else:
				upgrade_values.append("[color=green]%s[/color]" % [value])
		description += "%s\n" % [upgrade_values.join(" / ")]  

	var cost = _get_cost()

	if editable && deck_upgrade_data.unlock_index < 0:
		if Global.is_mobile():
			seleted_details.bbcode_text = "%s: %s %s" % [tr("UNLOCK"), cost, coin_icon]
			seleted_details.show()
		else:
			unlock_button.get_node("tooltip").text = "Unlock: %s %s" % [cost, coin_icon] 
	elif editable && deck_upgrade_data.max_index == deck_upgrade_data.unlock_index && deck_upgrade_data.unlock_index < selected_upgrade.value.size() - 1:
		if Global.is_mobile():
			seleted_details.bbcode_text = "Unlock next level: %s %s" % [cost, coin_icon]
			seleted_details.show()
		else:
			upgrade_button.get_node("tooltip").text = "%s: %s %s" % [tr("UNLOCK_NEXT_LEVEL"), cost, coin_icon] 
			
	selected_description.bbcode_text = description

	visible_button.pressed = deck_upgrade_data.active 


func _get_cost():
	var deck_upgrade_data = deck_data[selected_upgrade.id]
	var cost = Global.DECK_CARD_UPGRADE_COST
	if deck_upgrade_data.unlock_index + 1 <= selected_upgrade.value.size() - 1 && 'cost' in selected_upgrade.value[deck_upgrade_data.unlock_index + 1]:
		cost = selected_upgrade.value[deck_upgrade_data.unlock_index + 1].cost
	elif 'cost' in selected_upgrade:
		cost = selected_upgrade.cost
	return cost
	

func _on_visible_button_pressed():
	var button = avaliable_container.get_node_or_null(selected_upgrade.id)
	var deck_upgrade_data = deck_data[selected_upgrade.id]
	if deck_upgrade_data.active:
		button.button.soft_disabled = true
		deck_upgrade_data.active = false
		button.text_label = "%s/%s" % [0, selected_upgrade.value.size()]
	else:
		deck_upgrade_data.active = true
		button.button.soft_disabled = false
		button.text_label = "%s/%s" % [deck_upgrade_data.max_index + 1, selected_upgrade.value.size()]
	# force update to remove disabled effect
	button.update()
	_on_card_focus_entered(selected_upgrade)


func _on_card_edit_popup_hide():
	Global.opened_popups_remove(self)


func _on_cancel_button_pressed():
	persist = false
	hide()


func _on_done_button_pressed():
	persist = true
	hide()


func _on_unlock_button_pressed():
	var cost = _get_cost()
	if cost > coins:
		return Global.add_toast_error(tr("NOT_ENOUGH_COINS"))
	coins -= cost
	meta_bar.set_coins(coins)

	var button = avaliable_container.get_node_or_null(selected_upgrade.id)
	var deck_upgrade_data = deck_data[selected_upgrade.id]

	deck_upgrade_data.active = true
	deck_upgrade_data.unlock_index = 0
	deck_upgrade_data.max_index = 0

	button.text_label = "%s/%s" % [deck_upgrade_data.max_index + 1, selected_upgrade.value.size()]
	button.button.soft_disabled = false
	# force update to remove disabled effect
	button.update()

	var locked_icon = button.get_node_or_null('locked_icon')
	if locked_icon:
		button.remove_child(locked_icon)

	_on_card_focus_entered(selected_upgrade)
	visible_button.grab_focus()


func _on_downgrade_button_pressed():
	var button = avaliable_container.get_node_or_null(selected_upgrade.id)
	var deck_upgrade_data = deck_data[selected_upgrade.id]
	deck_upgrade_data.max_index -= 1
	button.text_label = "%s/%s" % [deck_upgrade_data.max_index + 1, selected_upgrade.value.size()]
	if deck_upgrade_data.max_index < 0:
		deck_upgrade_data.max_index = 0
		deck_upgrade_data.active = false
		button.soft_disabled = true
		# force update to remove disabled effect
		button.update()
	_on_card_focus_entered(selected_upgrade)


func _on_upgrade_button_pressed():
	var button = avaliable_container.get_node_or_null(selected_upgrade.id)
	var deck_upgrade_data = deck_data[selected_upgrade.id]
	if deck_upgrade_data.max_index < deck_upgrade_data.unlock_index:
		deck_upgrade_data.max_index += 1
	elif deck_upgrade_data.unlock_index < selected_upgrade.value.size() - 1:
		var cost = _get_cost()
		if cost > coins:
			return Global.add_toast_error(tr("NOT_ENOUGH_COINS"))
		coins -= cost
		meta_bar.set_coins(coins)

		deck_upgrade_data.unlock_index += 1
		deck_upgrade_data.max_index += 1
	button.text_label = "%s/%s" % [deck_upgrade_data.max_index + 1, selected_upgrade.value.size()]
	button.button.soft_disabled = false
	# force update to remove disabled effect
	button.update()
	_on_card_focus_entered(selected_upgrade)


func _on_language_changed():
	selected_label.set('custom_fonts/font', Global.get_font(_config.selected_label_font))  
	selected_description.set('custom_fonts/normal_font', Global.get_font(_config.selected_description_font)) 
	seleted_details.set('custom_fonts/normal_font', Global.get_font(_config.selected_details_font))



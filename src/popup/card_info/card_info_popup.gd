extends Popup

signal upgrades_button_pressed(card_data)

var card_data

var _default_config = {
	card_size = Vector2(120, 200),
	container_margin_top = 10,
	actions_size = Vector2(20, 20),
	actions_separation = 4,
	label_font = 12,
	description_font = 8,
	details_font = 8,
	details_height = 30,
}

var _mobile_config = {
	card_size = Vector2(160, 224),
	container_margin_top = 0,
	actions_size = Vector2(64, 28),
	actions_separation = 8,
	label_font = 16,
	description_font = 12,
	details_font = 12,
	details_height = 40,
}

var _config = _default_config

onready var container = $container
onready var bg_material = $bg.material
onready var icon_node = $"%texture"
onready var label_node = $"%label"
onready var description_node = $"%description"
onready var details_node = $"%details"
onready var close_button = $"%close_button"
onready var upgrades_button = $"%upgrades_button"
onready var actions_row = $container/actions_row
onready var details_container = $container/card_row/card_container/content/details_container

func _ready():
	if Global.is_mobile():
		_config = _mobile_config
	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")

	container.margin_top = _config.container_margin_top
	$container/card_row/card_container.rect_min_size = _config.card_size
	$container/actions_row/actions.set("custom_constants/separation", _config.actions_separation)
	close_button.rect_min_size = _config.actions_size
	upgrades_button.rect_min_size = _config.actions_size
	details_container.rect_min_size.y = _config.details_height


func open(data):
	card_data = data
	icon_node.texture = data.icon
	upgrades_button.visible = 'upgrades_data' in data
	if is_instance_valid(Global.player) && !Global.player.deck.cards.has(data.id):
		upgrades_button.hide()
	else:
		var selected_char_id = Persistent.get_data('selected_char_id')
		var selected_deck = Persistent.get_data('selected_deck') 
		var selected_deck_id = selected_deck[selected_char_id]
		var deck = Persistent.get_deck(selected_deck_id)
		if !deck || !deck.cards.has(data.id):
			upgrades_button.hide()

	update_texts(data)
	Global.theme_bg_overlay($bg)

	Global.opened_popups_add(self, { popup_tween_container = container })
	popup()


func update_texts(data):
	var description = data.format_description()
	if 'require_description' in data:
		description += "\n\n%s" % [tr(data.require_description)]
	if description:
		description += "\n\n"
	description += "%s" % [data.format_info()]
		
	label_node.bbcode_text = "[center]%s[/center]" % [tr(data.label)] 
	description_node.bbcode_text = "[center]%s[/center]" % [description]

	if is_instance_valid(Global.player) && Global.player.has_spell(data.id):
		if !Global.player.deck.cards.has(data.id):
			details_node.bbcode_text = "[center]%s %s\n%s[/center]" % [tr('LEVEL'), data.level, data.format_details()]
		else:
			details_node.bbcode_text = "[center]%s\n%s[/center]" % [data.format_level(), data.format_details()]
	else:
		var upgrades_size = data.format_upgrades_size()
		if upgrades_size:
			details_node.bbcode_text = "[center]%s\n%s[/center]" % [upgrades_size, data.format_details()]
		else:
			details_node.bbcode_text = "[center]%s[/center]" % [data.format_details()]


func _on_bg_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			hide()
	

func _on_language_changed():
	label_node.set('custom_fonts/font', Global.get_font(_config.label_font))
	description_node.set('custom_fonts/normal_font', Global.get_font(_config.description_font)) 
	details_node.set('custom_fonts/normal_font', Global.get_font(_config.details_font)) 


func _on_card_info_popup_hide():
	Global.opened_popups_remove(self)


func _on_close_button_pressed():
	hide()


func _on_upgrades_button_pressed():
	emit_signal("upgrades_button_pressed", card_data)

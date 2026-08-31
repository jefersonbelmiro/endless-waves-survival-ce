extends Popup

const button_scene = preload("res://src/popup/backpack/components/button/backpack_button.tscn")

var rank_index: int
var data: Dictionary

onready var container = $container
onready var content_label = $"%content_label"
onready var text_rows = $"%text_rows"


func _ready():
	if !data || !('payload' in data):
		_create_invalid_data_text()
		return
	var payload = JSON.parse(data.payload).result
	if !payload:
		_create_invalid_data_text()
		return

	Global.theme_bg_overlay($bg)
	Global.theme_bg($container/bg_color)
	Global.theme_panel_border($container/bg_border)

	content_label.text = "#%s %s" % [rank_index + 1, data.user_name]
	content_label.hide()

	Global.node_remove_children(text_rows)

	_create_text_row("SCOREBOARD_ENTRY_NAME", data.user_name)
	_create_text_row("SCOREBOARD_ENTRY_RANK", "#%s" % [rank_index + 1])
	_create_text_row("SCORE", Formatter.format_number(data.score))
	var char_label = Entities.chars_data_map.get(payload.char_id).label
	_create_text_row("CHARACTER", char_label)
	_create_text_row("LEVEL", payload.player_level)
	_create_text_row("DURATION", Formatter.format_ellapsed(payload.time_ellapsed))
	_create_text_row("COINS_EARNED", Formatter.format_number(payload.coins))
	var kills = payload.get('kills')
	if kills:
		_create_text_row("ENEMIES_DEFEATED", Formatter.format_number(int(kills)))
	_create_text_row("DAMAGE_TAKEN", Formatter.format_number(int(payload.player_damage_taken)))
	var map_label = Entities.maps_data_map.get(payload.map_id, '').get('label')
	_create_text_row("MAP", map_label)

	if payload.consumables.size():
		_create_header_text_row("BACKPACK")
		for id in payload.consumables:
			var label = Entities.consumables_data_map[id].label
			_create_text_row("%s" % label, payload.consumables[id])

	if payload.traits.size():
		_create_header_text_row("TRAITS")
		for trait_data in payload.traits:
			var trait_label = Traits.avaliable_data[trait_data.id].label
			var trait_level = trait_data.size
			if !trait_level:
				continue
			_create_text_row("%s" % trait_label, trait_level)

	if payload.spell_level.size():
		_create_header_text_row("CARDS")
		for id in payload.spell_level:
			var spell_label = Entities.spells_data_map[id].label
			var spell_level = payload.spell_level[id]
			if !spell_level:
				continue
			_create_text_row("%s" % spell_label, spell_level)
	

func open():
	Global.opened_popups_add(self)
	popup()


func _on_cancel_button_pressed():
	hide()


func _on_confirm_popup_hide():
	Global.opened_popups_remove(self)
	queue_free()



func _create_text_row(label_text: String, value):
	var cols = HBoxContainer.new()
	# cols.size_flags_horizontal = SIZE_EXPAND_FILL
	text_rows.add_child(cols)

	var label = _create_label("%s:" % [tr(label_text)])
	# label.clip_text = true
	# label.valign = Label.VALIGN_CENTER
	# label.rect_min_size.x = 100
	# label.size_flags_horizontal = SIZE_EXPAND_FILL
	cols.add_child(label)
	
	var value_str = str(value)
	var value_label = _create_label(value_str, true)
	# value_label.align = Label.ALIGN_LEFT
	# value_label.align = Label.ALIGN_RIGHT
	# value_label.valign = Label.VALIGN_CENTER
	# value_label.size_flags_vertical = SIZE_EXPAND_FILL
	cols.add_child(value_label)
	

	# var separator = HSeparator.new()
	# separator.modulate = Color('#484848')
	# separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#
	# text_rows.add_child(separator)



func _create_header_text_row(label_text: String):
	var spacer = Control.new()
	spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	spacer.rect_min_size = Vector2(0, 5)
	text_rows.add_child(spacer)

	var label = _create_label("%s" % [tr(label_text)], true)
	text_rows.add_child(label)
	_create_separator()


func _create_label(text: String, highlight = false):
	var label = Label.new()
	label.text = text
	label.set('custom_fonts/font', Global.get_font(12))
	label.set('custom_colors/font_color', Color('#dddddd') if highlight  else Color('#acaaaa'))
	return label


func _create_separator():
	var separator = HSeparator.new()
	separator.modulate = Color('#484848')
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_rows.add_child(separator)


func _create_invalid_data_text():
	# @TODO add translations
	var label = _create_label("SCOREBOARD_INVALID_ENTRY")
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.size_flags_vertical = SIZE_EXPAND_FILL
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	text_rows.add_child(label)

	content_label.hide()
	


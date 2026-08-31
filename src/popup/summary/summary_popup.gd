extends Popup

var _default_config = {
	actions_height = 20,
	row_font = 8,
}
var _mobile_config = {
	actions_height = 32,
	row_font = 12,
}
var _config = _default_config

onready var summary_container = $container/content/left_container/summary_container
onready var card_container = $container/content/right_container/scroll_container/card_container
onready var summary_label = $container/content/left_container/summary_label
onready var close_button = $"%close_button"

func _ready():
	if Global.is_mobile():
		_config = _mobile_config

	close_button.rect_min_size.y = _config.actions_height


func open(status):
	if status == Global.OBJECTIVE_STATUS.WIN:
		summary_label.text = "VICTORY"
		summary_label.modulate = Color.green
	elif status == Global.OBJECTIVE_STATUS.LOSE:
		summary_label.text = "DEFEAT"
		summary_label.modulate = Color.red
	else:
		summary_label.text = "QUIT"
		summary_label.modulate = Color.yellow
	summary_label.modulate.a = 0.8
		
	# player_dead_effect change time_scale
	Engine.time_scale = 1
	Global.set_paused(true)

	_create_summary()
	_create_cards_summary()
	
	Global.opened_popups_add(self)
	popup()


func _create_summary():
	var survived = Formatter.format_ellapsed(Global.time_ellapsed)
	var coins = Formatter.format_number(Global.log_data.coins)
	var level = str(Global.log_data.player_level)
	var kills = Formatter.format_number(Global.kills)
	var damage_taken = Formatter.format_number(Global.log_data.player_damage_taken)
	var map = Global.map.format_label()

	Global.node_remove_children(summary_container)
	summary_container.add_child(_create_row("MAP", map))
	summary_container.add_child(_create_row("SURVIVED", survived))
	summary_container.add_child(_create_row("COINS_EARNED", coins))
	summary_container.add_child(_create_row("LEVEL_REACHED", level))
	summary_container.add_child(_create_row("ENEMIES_DEFEATED", kills))
	summary_container.add_child(_create_row("DAMAGE_TAKEN", damage_taken))
	if Global.log_data.player_deaths > 1:
		summary_container.add_child(_create_row("DEATHS", str(Global.log_data.player_deaths)))


func _create_cards_summary():
	var damage_data = Global.log_data.spell_damage
	var level_data = Global.log_data.spell_level
	Global.node_remove_children(card_container)
	for card_id in damage_data.keys():
		var card_data = Database.get_card(card_id)
		if !card_data:
			continue
		var damage_suffix = tr('DAMAGE')
		if card_id == 'shield':
			damage_suffix = tr('DAMAGE_BLOCKED')
		var damage = "%s %s" % [Formatter.format_number(damage_data[card_id]), damage_suffix]
		var level = level_data[card_id]
		var label = "%s (%s)" % [tr(card_data.label), level]
		card_container.add_child(_create_row(label, damage))


func _create_row(label_text: String, value_text: String):
	var container = HBoxContainer.new()
	var label_node = _create_label(label_text)
	var value_node = _create_label(value_text)
	label_node.size_flags_horizontal = label_node.SIZE_EXPAND_FILL
	container.add_child(label_node)
	container.add_child(value_node)
	return container

	
func _create_label(text: String):
	var label = Label.new()
	label.text = text
	label.set('custom_fonts/font', Global.get_font(_config.row_font))
	label.set('custom_colors/font_color', Color('#acaaaa'))
	return label


func _on_restart_button_pressed():
	Global.set_paused(false)
	var _changed = get_tree().reload_current_scene();


func _on_menu_button_pressed():
	Global.set_paused(false)
	get_tree().change_scene_to(Global.menu_screen_scene)
	

func _on_summary_popup_hide():
	Global.opened_popups_remove(self)


func _on_close_button_pressed():
	hide()

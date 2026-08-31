extends Control


var card_edit_popup

var _default_config = {
	grid_item_size = Vector2(20, 20),
}

var _mobile_config = {
	grid_item_size = Vector2(32, 32),
}

var _config = _default_config
var last_focus

onready var grid = $grid
onready var card_info_popup = $card_info_popup

func _ready():
	if !Global.is_mobile():
		get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")
	

func grab_focus():
	if is_instance_valid(last_focus) && last_focus.is_inside_tree():
		last_focus.grab_focus()
	elif grid.get_child_count():
		grid.get_child(0).grab_focus()

	var rows = ceil(grid.get_child_count()/grid.columns)
	var path_neighbour_right = get_node(focus_neighbour_right).get_path()
	for row_index in range(1, rows + 1):
		var child_index = min(row_index * grid.columns - 1, grid.get_child_count() - 1)
		var node = grid.get_child(child_index)
		node.focus_neighbour_right = path_neighbour_right


func update():
	if Global.is_mobile():
		_config = _mobile_config

	grid.clear()
	grid.item_size = _config.grid_item_size.x

	var cards = []
	for id in Global.player.spells.keys():
		var data = Global.player.spells[id].get_data()
		if 'visible' in data && !data.visible:
			continue
		cards.append(data)
	cards.sort_custom(Entities, "_sort_spell_handler")
	
	for index in cards.size():
		var node = _create_button(cards[index])
		grid.add_child(node)


func _create_button(data):
	var button = Global.deck_card_button_scene.instance()
	button.cast_type = data.cast_type
	button.icon_texture = data.icon
	button.rect_min_size = _config.grid_item_size
	button.hint_tooltip = data.label
	button.connect("pressed", self, "_on_card_button_pressed", [data])
	return button
									

func _on_card_button_pressed(data):
	card_info_popup.open(data)


func _on_card_info_popup_upgrades_button_pressed(card_data):
	if !card_edit_popup:
		card_edit_popup = Global.card_edit_popup_scene.instance()
		add_child(card_edit_popup)
	
	var deck = Persistent.get_deck(Global.session.current_deck_id)
	var coins = Persistent.get_coins()
	card_edit_popup.open(card_data, deck, coins, false)


func _on_gui_focus_changed(control):
	if !is_visible_in_tree() || control == self:
		return
	if !is_instance_valid(control) || !control.is_inside_tree() || !is_inside_tree():
		return
	var is_child = str(control.get_path()).begins_with(str(get_path()))
	if !is_child:
		return
	last_focus = control


func _on_player_cards_focus_entered():
	grab_focus()

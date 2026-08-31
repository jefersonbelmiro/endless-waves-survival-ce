extends Popup

const current_button_scene = preload("res://src/popup/backpack/components/button/backpack_button.tscn")

var current_data
var selected_data
var focused_data
var coins: int

var _default_config = {
	actions_height = 20,
	container_magin_bottom = -10,
	grid_item_size = 20,
	grid_item_font_size = 12,
	current_container_width = 108,
	selected_width = 120,
	selected_label_font = 16,
	selected_description_font = 8,
	selected_cost_font = 12,
	selected_actions_height = 20,
}

var _mobile_config = {
	actions_height = 32,
	container_magin_bottom = -4,
	grid_item_size = 40,
	grid_item_font_size = 16,
	current_container_width = 108,
	selected_width = 200,
	selected_label_font = 16,
	selected_description_font = 16,
	selected_cost_font = 16,
	selected_actions_height = 32,
}


var _config = _default_config

onready var current_container = $container/content/current/grid
onready var avaliable_container = $container/content/avaliable/grid
onready var selected_icon = $container/content/selected/content/header/icon_container/icon
onready var selected_label = $container/content/selected/content/header/label_container/label
onready var selected_description = $container/content/selected/content/description_container/description
onready var actions_container = $container/content/selected/content/actions_container
onready var add_button = $container/content/selected/content/actions_container/add_button
onready var sell_button = $container/content/selected/content/actions_container/sell_button
onready var meta_bar = $meta_bar
onready var cost_container = $container/content/selected/content/cost_constainer
onready var cost_label = $container/content/selected/content/cost_constainer/cost_label
onready var cost_value = $container/content/selected/content/cost_constainer/cost_value

func _ready():
	if Global.is_mobile():
		_config = _mobile_config
		$container/actions_hint.hide()
	
	$container/content/current.rect_min_size.x = _config.current_container_width
	current_container.item_size = _config.grid_item_size
	avaliable_container.item_size = _config.grid_item_size

	$container/content/selected.rect_min_size.x = _config.selected_width
	actions_container.rect_min_size.y = _config.selected_actions_height
	add_button.rect_min_size.y = _config.selected_actions_height
	sell_button.rect_min_size.y = _config.selected_actions_height

	$container.margin_bottom = _config.container_magin_bottom
	$container/actions.rect_min_size.y = _config.actions_height
	$container/actions/cancel_button.rect_min_size.y  = _config.actions_height
	$container/actions/done_button.rect_min_size.y = _config.actions_height

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")
	
	Global.theme_bg($bg)
	Global.theme_panel_bg($container/content/current/bg)
	Global.theme_panel_border($container/content/current/bg_border)
	Global.theme_panel_bg($container/content/avaliable/bg)
	Global.theme_panel_border($container/content/avaliable/bg_border)
	Global.theme_panel_bg($container/content/selected/bg)
	Global.theme_panel_border($container/content/selected/bg_border)
	
	if Global.is_plataform_crazygames():
		var crazygames_sdk = Global.load_crazygames_sdk()
		crazygames_sdk.configure_backpack_edit_popup(self)


func open():
	Global.opened_popups_add(self)
	popup()

	coins = Persistent.get_coins()
	meta_bar.set_coins(coins)

	current_data = Traits.start_current_edit()
	
	avaliable_container.clear()
	for uid in Traits.avaliable_data.keys():
		var data = Traits.avaliable_data.get(uid)
		avaliable_container.add_child(_create_avaliable_button(data))


	current_container.clear()
	for index in current_data.size():
		var node = _create_current_button()
		node.font_size = _config.grid_item_font_size
		_update_node(node, index)
		current_container.add_child(node)

	if avaliable_container.get_child_count():
		avaliable_container.get_child(0).grab_focus()
		

func _shadown_animation(data, node, ref_node):
	var ref_node_global_position = ref_node.get_global_position()
	var node_global_position = node.get_global_position()
	var shadow = _create_shadow_button(data)
	add_child(shadow)

	var distance = node_global_position - ref_node_global_position 
	var jump_position = (ref_node_global_position + distance.normalized() * distance.length() * 0.2 ) + Vector2(0, -50)
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(self, '_update_shadow_position', 0.0, 1.0, 0.4, [shadow, ref_node_global_position, jump_position, node_global_position])
	yield(tween, 'finished')
	shadow.queue_free()


# use quadratic bezier
# https://docs.godotengine.org/en/3.6/tutorials/math/beziers_and_curves.html
func _update_shadow_position(weight: float, shadow_node, start_position, jump_position, end_position):
	var q0 = start_position.linear_interpolate(jump_position, weight)
	var q1 = jump_position.linear_interpolate(end_position, weight)
	var position = q0.linear_interpolate(q1, weight)
	shadow_node.rect_global_position = position


func _has_on_current(data):
	for index in Traits.max_slots:
		if current_data[index].id == data.uid && current_data[index].size > 0:
			return true
	return false


func _create_shadow_button(data):
	var button = current_button_scene.instance()
	button.icon_texture = data.icon
	button.rect_min_size = Vector2(_config.grid_item_size, _config.grid_item_size)
	return button


func _create_current_button():
	var button = current_button_scene.instance()
	button.rect_min_size = Vector2(_config.grid_item_size, _config.grid_item_size)
	button.connect("pressed", self, "_on_card_pressed")
	button.connect("gui_input", self, "_on_current_button_gui_input", [button])
	button.connect("focus_entered", self, "_on_current_button_focus_entered", [button])
	return button


func _create_avaliable_button(data):
	var button = current_button_scene.instance()
	button.icon_texture = data.icon
	button.rect_min_size = Vector2(_config.grid_item_size, _config.grid_item_size)
	# button.bg_texture = load('res://assets/components/border_box_bg.png')
	# button.bg_color = Color('#774b7b')
	button.name = data.uid
	button.hint_tooltip = data.label
	button.connect("pressed", self, "_on_card_pressed")
	button.connect("gui_input", self, "_on_avaliable_button_gui_input", [data])
	button.connect("focus_entered", self, "_on_avaliable_button_focus_entered", [button])
	return button


func _on_card_pressed():
	if !InputSource.mouse && !Global.is_mobile():
		_focus_first_action()


func _focus_first_action():
	for index in actions_container.get_child_count():
		var node = actions_container.get_child(index)
		if node.visible:
			node.grab_focus()
			break


func _on_current_button_gui_input(event, node):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			var data = Traits.avaliable_data.get(node.name)
			if data:
				selected_data = data
				_sell(selected_data)
				SFX.add_button_pressed()
			else:
				SFX.add_button_error()


func _on_avaliable_button_gui_input(event, data):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			selected_data = data
			if selected_data.cost <= coins:
				SFX.add_button_pressed()
			else:
				SFX.add_button_error()
			_add_card(data)


func _on_current_button_focus_entered(node):
	var trait_data = current_data[node.get_index()]
	if !trait_data || !trait_data.size:
		focused_data = null
	else:
		focused_data = Traits.avaliable_data.get(trait_data.id)
	_on_focus_card(focused_data)


func _on_avaliable_button_focus_entered(node):
	focused_data = Traits.avaliable_data.get(node.name)
	_on_focus_card(focused_data)


func _add_trait_item(data):
	var add_index = -1
	for index in current_data.size():
		if current_data[index].id == data.uid && current_data[index].size > 0:
			add_index = index
			break
		elif add_index == -1 && current_data[index].size == 0:
			add_index = index
	if add_index != -1:
		var curr_data = current_data[add_index]
		if curr_data.id && curr_data.size + 1 > data.stack_max:
			Global.add_toast_error(tr("CONSUMABLE_MAX_STACK_TOAST_CANT_USE"))
			return null
		if curr_data.size > 0:
			curr_data.size += 1
		else:
			current_data[add_index] = { size = 1, id = data.uid }
	if add_index == -1:
	   Global.add_toast_error("traits is full")
	   return null
	return add_index

	
func _add_card(data):
	if data.cost > coins:
		return
	var index = _add_trait_item(data)
	if index == null:
	   return

	coins -= data.cost
	meta_bar.set_coins(coins)

	var button = current_container.get_child(index)
	var ref_node = avaliable_container.get_node_or_null(data.uid)
	yield(_shadown_animation(data, button, ref_node), "completed")
	_update_current_grid()
	_update_actions_state()
	_on_focus_card(focused_data)
	

func _sell(data):
	var remove_index = -1

	for index in current_data.size():
		if current_data[index].id == data.uid && current_data[index].size > 0:
			remove_index = index
			break

	if remove_index == -1:
		return
		
	var remove_size = current_data[remove_index].size

	coins += data.cost * remove_size
	meta_bar.set_coins(coins)

	current_data[remove_index] = { id = null, size = 0 }

	var button = avaliable_container.get_node_or_null(data.uid)
	var ref_node = current_container.get_child(remove_index)
	_update_current_grid()
	_update_actions_state()
	yield(_shadown_animation(data, button, ref_node), "completed")

	_on_focus_card(focused_data)


func _update_current_grid():
	for index in current_data.size():
		var node = current_container.get_child(index)
		_update_node(node, index)


func _update_node(node, index):
	var item = { size = 0, id = null }
	if current_data[index]:
		item = current_data[index]
	if item.size == 0:
		node.name = 'empty_%s' % [index]
		node.size = 0
		node.icon_texture = null
		node.hint_tooltip = ''
		return
	node.name = item.id
	node.size = item.size
	node.icon_texture = Traits.avaliable_data.get(item.id).icon
	node.hint_tooltip = Traits.avaliable_data.get(item.id).label


func _on_focus_card(data):
	_update_actions_state()
	if !data:
		selected_icon.texture = null
		selected_label.text = ''
		selected_description.bbcode_text = ''
		cost_container.hide()
		return

	cost_value.text = str(data.cost)
	cost_container.show()
	selected_icon.texture = data.icon
	selected_label.text = data.label

	var description = data.format_description()
	selected_description.bbcode_text = description
	

func _update_actions_state():
	add_button.hide()
	sell_button.hide()

	if focused_data:
		add_button.show()
		add_button.disabled = coins < focused_data.cost
		sell_button.visible = _has_on_current(focused_data)  


func _on_done_button_pressed():
	Traits.end_current_edit()
	Persistent.set_data('meta.traits', Traits.current)
	Persistent.set_data('meta.coins', coins)
	Persistent.save_data()
	hide()


func _on_cancel_button_pressed():
	hide()


func _on_add_button_pressed():
	var result = _add_card(focused_data)
	if result:
		yield(result, 'completed')
	if visible:
		_focus_first_action()


func _on_sell_button_pressed():
	_sell(focused_data)
	_focus_first_action()


func _on_language_changed():
	selected_label.set('custom_fonts/font', Global.get_font(_config.selected_label_font))
	selected_description.set('custom_fonts/normal_font', Global.get_font(_config.selected_description_font))
	cost_label.text = "%s:" % [tr("COST")]
	cost_label.set('custom_fonts/font', Global.get_font(_config.selected_cost_font))
	cost_value.set('custom_fonts/font', Global.get_font(_config.selected_cost_font))


func _on_traits_popup_popup_hide():
	Global.opened_popups_remove(self)

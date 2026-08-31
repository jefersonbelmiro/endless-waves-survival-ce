extends Popup

var _animation_speed_scale = 0.5
var _status: int

var _default_config = {
	actions_height = 20,
	label_font = 16,
	row_font = 8,
}
var _mobile_config = {
	actions_height = 32,
	label_font = 24,
	row_font = 16,
}
var _config = _default_config
var additional_rows = []

onready var container = $container
onready var start_position = $container.rect_position
onready var label = $container/content/label
onready var rows_container = $container/content/rows_container
onready var rows = $container/content/rows_container/rows

func _ready():
	if Global.is_mobile():
		_config = _mobile_config

	label.set('custom_fonts/font', Global.get_font(_config.label_font))

	var actions_container = $actions
	for index in actions_container.get_child_count():
		var node = actions_container.get_child(index)
		node.rect_min_size.y = _config.actions_height
	actions_container.rect_min_size.y = _config.actions_height
	actions_container.rect_position.y = rect_size.y - 20 - _config.actions_height

	set_process_input(false)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_animation_speed_scale = 0.05
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT:
			_animation_speed_scale = 0.05


func open(status: int):
	_status = status
	if status == Global.OBJECTIVE_STATUS.WIN:
		label.text = "VICTORY"
	elif status == Global.OBJECTIVE_STATUS.LOSE:
		label.text = "DEFEAT"
	else:
		label.text = "QUIT"

	# player_dead_effect change time_scale
	Engine.time_scale = 1
	Global.set_paused(true)

	var bonus_coins = Global.session.map.coins_complete_objectives + Global.session.map.coins_unlock_level 
	var collected_coins = Global.player.coins - bonus_coins

	_create_row("COINS", collected_coins)
	_create_row("SURVIVED", Formatter.format_ellapsed(Global.time_ellapsed))
	_create_row("ENEMIES_DEFEATED", Formatter.format_number(Global.kills))

	if Global.session.map.new_high_score:
		_create_row("NEW_HIGH_SCORE", Formatter.format_number(Global.calcule_score()))
	else:
		_create_row("SCORE", Formatter.format_number(Global.calcule_score()))

	for index in additional_rows.size():
		var row = additional_rows[index]
		_create_row(row.label, row.value)

	if status == Global.OBJECTIVE_STATUS.WIN:
		_create_row("BONUS_COINS", bonus_coins)
		if Global.session.map.coins_unlock_level:
			var unlock_message = tr("UNLOCKED_MAP_LEVEL").format({
				level = Persistent.get_map(Global.session.current_map_id).unlock_level 
			})
			_create_row("UNLOCKED", unlock_message)

	_create_initial_tween()
	set_process_input(true)

	popup()
	Global.opened_popups_add(self, { popup_tween = false })

	get_tree().create_timer(0.2 * _animation_speed_scale).connect("timeout", SFX, "add_popup")
	container.rect_size = Vector2(rect_size.x, 40)
	container.rect_position = Vector2(0, (rect_size.y - 40) / 2) 


func _create_initial_tween():
	container.rect_pivot_offset = container.rect_size/2
	container.rect_scale.y = 0
	container.modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(container, 'rect_scale:y', 1.0, 0.5 * _animation_speed_scale)
	tween.tween_property(container, 'modulate:a', 1.0, 0.3 * _animation_speed_scale)
	tween.connect("finished", self, "_on_initial_tween_finished")


func _on_initial_tween_finished():
	get_tree().create_timer(0.5 * _animation_speed_scale).connect("timeout", self, "_create_container_tween")


func _create_container_tween():
	label.rect_min_size.y = 30
	rows_container.show()

	var string_height = Global.get_font(_config.row_font).get_height()
	rows_container.rect_size.y += rows.get_child_count() * string_height

	rows.set_anchors_and_margins_preset(rows.PRESET_CENTER_TOP)
	rows.rect_position.y -= 5

	var container_size_y = container.rect_size.y + rows_container.rect_size.y   
	var container_position_y = container.rect_position.y - rows_container.rect_size.y/2   
	var container_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	container_tween.tween_property(container, "rect_size:y", container_size_y, 0.2 * _animation_speed_scale)
	container_tween.tween_property(container, "rect_position:y", container_position_y, 0.2 * _animation_speed_scale)
	container_tween.connect("finished", self, "_create_rows_tween")


func _create_rows_tween():
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	for index in rows.get_child_count():
		var node = rows.get_child(index)
		node.rect_position.x = -30
		tween.tween_property(node, "modulate:a", 1.0, 0.6).set_delay(0.4 * index * _animation_speed_scale)
		tween.tween_property(node, "rect_position:x", 0.0, 0.8).set_delay(0.4 * index * _animation_speed_scale)
	tween.connect("finished", self, "_on_rows_tween_finished")


func _on_rows_tween_finished():
	$actions.show()
	$bg_dark.show()
	$bg_dark.modulate.a = 0

	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property($bg_dark, "modulate:a", 0.45, 0.6 * _animation_speed_scale)

	var action_position_y = $actions.rect_position.y
	$actions.rect_position.y += 50
	$actions.get_child(0).grab_focus()
	tween.parallel().tween_property($actions, "rect_position:y", action_position_y, 0.6 * _animation_speed_scale)


func _create_row(label_text: String, value):
	var box_node = HBoxContainer.new() 
	box_node.modulate.a = 0
	box_node.size_flags_horizontal = SIZE_EXPAND_FILL
	box_node.rect_min_size = Vector2(300, 0)

	var label_node = Label.new()
	label_node.set('custom_fonts/font', Global.get_font(_config.row_font))
	label_node.set('custom_colors/font_color', Color("#acaaaa"))
	label_node.text = "%s:" % [tr(label_text)]
	label_node.align = Label.ALIGN_RIGHT
	label_node.valign = Label.VALIGN_CENTER
	label_node.size_flags_horizontal = SIZE_EXPAND_FILL
	box_node.add_child(label_node)

	var value_node = Label.new()
	value_node.set('custom_fonts/font', Global.get_font(_config.row_font))
	value_node.set('custom_colors/font_color', Color("#00a000"))
	value_node.text = str(value)
	value_node.align = Label.ALIGN_LEFT
	value_node.valign = Label.VALIGN_CENTER
	value_node.size_flags_horizontal = SIZE_EXPAND_FILL
	box_node.add_child(value_node)

	rows.add_child(box_node)


func _on_menu_button_pressed():
	Global.set_paused(false)
	get_tree().change_scene_to(Global.menu_screen_scene)


func _on_restart_button_pressed():
	if Global.is_plataform_crazygames():
		var crazygames_sdk = Global.load_crazygames_sdk()
		return crazygames_sdk.restart()

	Global.set_paused(false)
	var _changed = get_tree().reload_current_scene();


func _on_summary_button_pressed():
	Global.hud.summary_popup.open(_status)


func _on_objective_status_popup_resized():
	if container:
		container.rect_size = Vector2(rect_size.x, container.rect_size.y)
		container.rect_position = Vector2(0, (rect_size.y - container.rect_size.y) / 2) 


func _on_objective_status_popup_hide():
	additional_rows = []
	Global.opened_popups_remove(self)

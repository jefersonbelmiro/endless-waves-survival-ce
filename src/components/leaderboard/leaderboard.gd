extends Control

var _default_config = {
	row_font = 12,
	hint_font = 8,
}
var _mobile_config = {
	row_font = 14,
	hint_font = 12,
}
var _config = _default_config
var label_color = Color('acaaaa')
var label_highlight_color = Color('#ffffff')

onready var rows = $control/rows
onready var not_sent_label = $control/not_sent_label

func _ready():
	hide()
	Global.persistent_load_connect(self, '_update')
	Firebase.connect("leaderboard_loaded", self, "_on_leaderboard_loaded")
	Firebase.connect("leaderboard_changed", self, "_on_leaderboard_changed")
	Settings.connect("changed", self, "_on_settings_changed")

	rows.add_child(_create_label(tr("UPDATING") + "...", false, false))


func update():
	Global.debounce_func(self, "_update")


func _update():
	_clear_rows()
	not_sent_label.hide()
	var score_data = Persistent.get_score_data()
	if score_data.leaderboard.size():
		show()
	else:
		return

	var rows_data = []
	var best_score = Global.get_persited_high_score()
	var found_player = false

	for index in score_data.leaderboard.size():
		var item = score_data.leaderboard[index].duplicate(true)
		if !found_player && item.is_player:
			found_player = true
			item.score = best_score
		rows_data.append(item)

	if !found_player:
		var user_name = score_data.user_name if score_data.user_name else tr('YOU')
		rows_data.append({
			user_name = user_name,
			score = best_score,
			is_player = true,
		})
	if !found_player && best_score && !score_data.last_score_sended && !score_data.user_name:
		not_sent_label.show()

	rows_data.sort_custom(self, '_sort_by_score')
	
	for index in rows_data.size():
		var item = rows_data[index]
		if !'user_name' in item:
			continue
		var user_name = item.user_name 
		if item.is_player && score_data.user_name:
			user_name = score_data.user_name
		var rank = index + 1
		if index > Firebase.LEADERBOARD_SIZE - 1:
			rank = "?"
		if index > Firebase.LEADERBOARD_SIZE - 1 && !item.is_player:
			continue
		_create_row("#%s %s" % [rank, user_name], item.score, item.is_player, item, index)


func _clear_rows():
	for index in rows.get_child_count():
		if index == 0:
			continue
		rows.get_child(index).queue_free()


func _create_hint_tooltip(index, item):
	var score_data = Persistent.get_score_data()
	var user_name = item.user_name 
	if item.is_player && score_data.user_name:
		user_name = score_data.user_name
	var texts = PoolStringArray()
	# texts.append("#%s | %s | %s" % [index, user_name, item.score])
	texts.append("position: %s" % [index])
	texts.append("name: %s" % [user_name])
	texts.append("score: %s" % [item.score * 1000])
	if 'os_name' in item:
		texts.append("OS: %s" % [item.os_name])
	# if 'map_id' in item:
	# 	var map_data = Database.get_map(item.map_id.replace('map_', '')) 
	# 	texts.append("map: %s" % [tr(map_data.label)])
	return texts.join("\n")


func _create_row(label_text: String, value: float, highlight = false, item = {}, rank_index = 0):
	var container = MarginContainer.new() 
	# container.rect_min_size = Vector2(148, 16)
	container.size_flags_horizontal = SIZE_EXPAND_FILL
	container.rect_min_size.y = 16

	var bg = ColorRect.new()
	bg.visible = false
	bg.color = Color(0, 0, 0, 0.5)
	bg.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	container.add_child(bg)

	container.connect("mouse_entered", self, "_on_row_mouse_entered", [bg])
	container.connect("mouse_exited", self, "_on_row_mouse_exited", [bg])
	container.connect("gui_input", self, "_on_row_gui_input", [item, rank_index])

	var cols = HBoxContainer.new()
	# cols.rect_min_size = Vector2(108, 16)
	cols.size_flags_horizontal = SIZE_EXPAND_FILL
	cols.size_flags_vertical = SIZE_EXPAND_FILL
	container.add_child(cols)
	rows.add_child(container)

	var label = _create_label(label_text, highlight)
	label.clip_text = true
	label.valign = Label.VALIGN_CENTER
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	cols.add_child(label)
	
	var value_str = str(value)
	var value_label = _create_label(value_str, highlight)
	value_label.align = Label.ALIGN_RIGHT
	value_label.valign = Label.VALIGN_CENTER
	value_label.size_flags_vertical = SIZE_EXPAND_FILL
	cols.add_child(value_label)
	

	var separator = HSeparator.new()
	separator.modulate = Color('#484848')
	# separator.size_flags_vertical = SIZE_SHRINK_END
	# separator.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# container.add_child(separator)

	rows.add_child(separator)
	

func _create_label(text: String, highlight = false, generic_font = true):
	var label = Label.new()
	label.text = text
	if generic_font:
		label.set('custom_fonts/font', Global.get_font(_config.row_font, 0, 'pt'))
	else:
		label.set('custom_fonts/font', Global.get_font(_config.row_font))
	label.set('custom_colors/font_color', label_highlight_color if highlight else label_color)
	return label
	

func _on_leaderboard_loaded(error):
	if error:
		Global.add_toast_error(tr("LEADERBOARD_LOAD_ERROR"))
	update()


func _on_leaderboard_changed():
	update()


func _on_settings_changed(key):
	if key != 'general.language':
		return
	update()
	not_sent_label.set('custom_fonts/font', Global.get_font(_config.hint_font))
	rows.get_child(0).set('custom_fonts/font', Global.get_font(_config.row_font))


func _sort_by_score(a, b):
	if !'score' in a || !'score' in b:
		return false
	return a.score > b.score


func _on_row_mouse_entered(bg):
	bg.visible = true

func _on_row_mouse_exited(bg):
	bg.visible = false

func _on_row_gui_input(event, item, rank_index):
	if !item.score:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			Global.add_score_detail_popup(item, rank_index)
	elif event is InputEventScreenTouch and event.pressed:
		Global.add_score_detail_popup(item, rank_index)

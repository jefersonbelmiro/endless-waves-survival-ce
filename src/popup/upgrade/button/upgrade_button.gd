extends Button

enum MODES { UPGRADING, LOCKING, DISCARDING }

export(MODES) var mode = MODES.UPGRADING
export var lock = false setget set_lock
export var discard = false setget set_discard
export var bg_color = Color(1, 1, 1)
export var bg_hover_color = Color(1, 1, 1)
export var bg_border_color = Color(1, 1, 1)
export var bg_hover_border_color = Color(1, 1, 1)

var data
var _disabled = false
var _focused = false
var _size = Vector2(120, 200)

var _default_config = {
	size = Vector2(120, 200),
	label_font = 12,
	description_font = 8,
	details_font = 8,
	badges_size = Vector2(12, 12),
	badges_font = 12,
}

var _mobile_config = {
	size = Vector2(142, 224),
	label_font = 16,
	description_font = 12,
	details_font = 12,
	badges_size = Vector2(20, 20),
	badges_font = 16,
}

var _config = _default_config

onready var bg_material = $bg.material
onready var icon_node = $"%texture"
onready var label_node = $"%label"
onready var description_node = $"%description"
onready var details_node = $"%details"

onready var lock_container = $"%lock_container"
onready var lock_border = $"%lock_border"
onready var discard_container = $"%discard_container"
onready var discard_border = $"%discard_border"

onready var badges_container = $"%badges_container"
onready var upgrades_size_border = $"%upgrade_size_border"
onready var upgrades_size_label = $"%upgrades_size_label"

onready var details_container = $container/details_container


func _init():
	if Global.is_mobile():
		_config = _mobile_config
		rect_min_size = _config.size


func _ready():
	icon_node.texture = data.icon
	
	bg_material.set_shader_param('color', bg_color)
	bg_material.set_shader_param('border_color', bg_border_color)
	lock_border.modulate = bg_border_color
	discard_border.modulate = bg_border_color
	upgrades_size_border.modulate = bg_border_color

	for index in badges_container.get_child_count():
		var node = badges_container.get_child(index)
		node.rect_min_size = _config.badges_size
	
	_update_texts()
	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")

	_disabled = disabled
	disabled = true
	create_popup_tween()

	if Global.is_mobile():
		description_node.get_v_scroll().rect_min_size.x = 12 

	Global.delay_func(self, "_check_details_size", 0.1, { pause_mode_process = true })


func set_lock(value: bool):
	lock = value
	if lock_container:
		update_focus()


func set_discard(value: bool):
	discard = value
	if discard_container:
		update_focus()


func create_popup_tween():
	rect_scale = Vector2(0.6, 0.6)
	modulate.a = 0
	rect_pivot_offset = rect_size/2
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(self, 'modulate:a', 1.0, 0.3)
	tween.tween_property(self, 'rect_scale', Vector2(1, 1), 0.3)
	tween.connect("finished", self, "_on_popup_tween_finished")


func _on_popup_tween_finished():
	disabled = _disabled
	

func update_focus():
	bg_material.set_shader_param('color', bg_hover_color if _focused else bg_color)
	bg_material.set_shader_param('border_color', bg_hover_border_color if _focused else bg_border_color )

	lock_container.visible = lock || mode == MODES.LOCKING
	lock_border.modulate = bg_hover_border_color if _focused && mode == MODES.LOCKING else bg_border_color

	discard_container.visible = discard || mode == MODES.DISCARDING
	discard_border.modulate = bg_hover_border_color if _focused && mode == MODES.DISCARDING else bg_border_color

	upgrades_size_border.modulate = bg_hover_border_color if _focused && mode == MODES.UPGRADING else bg_border_color


func _on_upgrade_button_focus_entered():
	_focused = true
	update_focus()


func _on_upgrade_button_focus_exited():
	_focused = false
	update_focus()


func _on_upgrade_button_mouse_entered():
	var focus_control = get_focus_owner()
	if focus_control && focus_control != self:
		focus_control.release_focus()
	grab_focus()


func _on_upgrade_button_button_down():
	SFX.add_button_pressed()         


func _update_texts():
	# label
	label_node.text = "%s" % [tr(data.label)] 
	
	# upgrades size
	var upgrades_size = 1
	if 'upgrades_data' in data && 'next_upgrades' in data && data.next_upgrades.size():
		upgrades_size = data.next_upgrades.size()
	upgrades_size_label.text = "%s" % [upgrades_size]

	# description
	var description = data.format_description()
	if 'require_description' in data:
		description += "\n\n%s" % [tr(data.require_description)]
	if description:
		description += "\n\n"
	description += "%s" % [data.format_info_with_upgrade()]
	description_node.bbcode_text = "[center]%s[/center]" % [description]

	# details
	details_node.text = "%s\n%s" % [data.format_level(), data.format_details()]


func _on_language_changed():
	label_node.set('custom_fonts/font', Global.get_font(_config.label_font))
	description_node.set('custom_fonts/normal_font', Global.get_font(_config.description_font)) 
	if Global.is_mobile():
		var details_font = Global.get_font(_config.details_font).duplicate(true)
		details_font.set_spacing(details_font.SPACING_BOTTOM, -3)
		details_node.set('custom_fonts/font', details_font)  
	else:
		details_node.set('custom_fonts/font', Global.get_font(_config.details_font))  
	upgrades_size_label.set('custom_fonts/font', Global.get_font(_config.badges_font))  
	_update_texts()


func _check_details_size():
	if details_node.get_line_count() > 3:
		details_container.rect_min_size.y = 48

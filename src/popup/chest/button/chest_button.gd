extends Button

export var bg_color = Color(1, 1, 1)
export var bg_hover_color = Color(1, 1, 1)
export var bg_border_color = Color(1, 1, 1)
export var bg_hover_border_color = Color(1, 1, 1)
export var target_position: Vector2

var data
var _type: String
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
	size = Vector2(160, 220),
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
onready var badges_container = $"%badges_container"
onready var upgrades_size_border = $"%upgrade_size_border"
onready var upgrades_size_label = $"%upgrades_size_label"

func _init():
	if Global.is_mobile():
		_config = _mobile_config
		rect_min_size = _config.size


func _ready():
	icon_node.texture = data.icon
	
	bg_material.set_shader_param('color', bg_color)
	bg_material.set_shader_param('border_color', bg_border_color)

	_type = data.uid.split("_")[0]
	if _type == "card" || _type == "spell":
		badges_container.show()
		badges_container.get_child(0).rect_min_size = _config.badges_size
		upgrades_size_border.modulate = bg_border_color

	_update_texts()
	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")

	_disabled = disabled
	disabled = true
	# create_popup_tween()


func create_popup_tween():
	rect_scale = Vector2(0.1, 0.1)
	# modulate.a = 1
	rect_pivot_offset = rect_size/2
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# tween.tween_property(self, 'modulate:a', 1.0, 0.1)
	tween.parallel().tween_property(self, 'rect_scale', Vector2(0.7, 0.7), 0.2)
	tween.parallel().tween_property(self, 'rect_position', target_position, 0.2)
	tween.tween_property(self, 'rect_scale', Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.connect("finished", self, "_on_popup_tween_finished")


func _on_popup_tween_finished():
	disabled = _disabled
	

func update_focus():
	bg_material.set_shader_param('color', bg_hover_color if _focused else bg_color)
	bg_material.set_shader_param('border_color', bg_hover_border_color if _focused else bg_border_color )

	upgrades_size_border.modulate = bg_hover_border_color if _focused else bg_border_color


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
	match _type:
		"card", "spell": _update_card_texts()
		"experience": _update_experience_texts()
		"coin": _update_coin_texts()
		"consumable": _update_consumable_texts()
		_: push_error("invalid type: " + _type)


func _update_consumable_texts():
	label_node.text = "%s" % [tr(data.label)] 

	var description = data.format_description()
	if '_size' in data:
		var size_text = "[color=green]%s[/color]" % [data._size]
		var collect_description = tr("CHEST_COLLECT_CONSUMABLE").format({ label = tr(data.label), size = size_text })
		description = "%s\n\n\n%s" % [collect_description, description]
	description_node.bbcode_text = "[center]%s[/center]" % [description]
	details_node.text = "%s" % ["CONSUMABLE"]


func _update_experience_texts():
	label_node.text = "%s" % [tr("EXPERIENCE")] 

	var value_text = "[color=green]%s[/color]" % [data.value]
	var description = tr("CHEST_COLLECT_EXPERIENCE").format({ value = value_text })
	description_node.bbcode_text = "[center]%s[/center]" % [description]


func _update_coin_texts():
	label_node.text = "%s" % [tr("COINS")] 

	var value_text = "[color=green]%s[/color]" % [data.value]
	var description = tr("CHEST_COLLECT_COINS").format({ value = value_text })
	description_node.bbcode_text = "[center]%s[/center]" % [description]


func _update_card_texts():
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
	details_node.set('custom_fonts/font', Global.get_font(_config.description_font))  
	upgrades_size_label.set('custom_fonts/font', Global.get_font(_config.badges_font))  
	_update_texts()

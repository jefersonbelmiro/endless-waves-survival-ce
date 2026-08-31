extends Control

export var action_name: String setget set_action_name

var action_list = {}

onready var icon = $texture_rect

func _ready():
	InputSource.connect("input_source_changed", self, "_on_input_source_changed")
	_set_icon(InputSource.source)


func set_action_name(value: String):
	if value == action_name:
		return
	action_name = value
	for event in InputMap.get_action_list(action_name):
		if event is InputEventKey:
			action_list[InputSource.KEYBOARD] = event.scancode
		elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
			action_list[InputSource.JOYPAD] = event.button_index
	_set_icon(InputSource.source)


func _set_icon(source):
	if !icon || !action_list.has(source):
		return
	var code = action_list[source]
	if source == InputSource.JOYPAD && Global.input_icons_res.button_index.has(code):
		icon.texture = Global.input_icons_res.button_index[code]
	elif source == InputSource.KEYBOARD && Global.input_icons_res.scancode.has(code):
		icon.texture = Global.input_icons_res.scancode[code]
	else:
		icon.texture = null


func _on_input_source_changed(source):
	_set_icon(source)
	

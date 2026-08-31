extends Node

signal input_source_changed(source)

enum { JOYPAD, TOUCH, KEYBOARD }

var source = KEYBOARD
var mouse = false

func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS)


func _input(event: InputEvent) -> void:
	mouse = false
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		if event.device == Global.session.controller_device:
			_set_source(JOYPAD)

	elif event is InputEventKey:
		_set_source(KEYBOARD)

	elif event is InputEventScreenDrag || event is InputEventScreenTouch:
		_set_source(TOUCH)
	
	elif event is InputEventMouse:
		mouse = true


func _set_source(value):
	if value == source:
		return
	source = value
	emit_signal('input_source_changed', source)

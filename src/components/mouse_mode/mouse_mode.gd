extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		 Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if event is InputEventMouseButton || event is InputEventMouseMotion:
		 Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

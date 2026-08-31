extends "res://src/components/drop/drop.gd"

onready var input_icon = $input/input_icon

func _ready():
	# disable/enable input handler
	set_process_input(!Global.is_mobile())
	# change area for non mobile plataforms
	$action_area/collision_shape_2d.shape.radius = 22 if !Global.is_mobile() else 11


func _input(event):
	if input_icon.visible && event.is_action_pressed("ui_action_active"):
		_open()


func _open():
	Global.emit_signal("chest_collected", value)
	queue_free()


func _on_action_area_body_entered(_body):
	if Global.is_mobile():
		_open()
	else:
		input_icon.show()


func _on_action_area_body_exited(_body):
	if input_icon.visible:
		input_icon.hide()

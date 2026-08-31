extends Node

var actived = false
var mode = 'direction'
var mode_node: Node
var mark_to_update = false

func _ready():
	# set_pause_mode(PAUSE_MODE_PROCESS)
	Global.connect("game_paused_changed", self, "_on_game_paused_changed")
	Settings.connect("changed", self, "_on_settings_changed")
	mode = Settings.get_aim_mode()
	set_mode()


func set_mode():
	get_parent().input_controller.with_aim_direction = true
	get_parent().input_controller.aim_mode = mode
	if Global.has_touchscreen():
		get_parent().input_controller.toggle_joystick_button_aim_direction()
	if is_instance_valid(mode_node):
		mode_node.queue_free()
	if mode == 'direction':
		mode_node = Global.input_aim_marker_scene.instance()
		get_parent().add_child(mode_node)
	elif mode == 'crosshair':
		mode_node = Global.crosshair_scene.instance()
		get_parent().add_child(mode_node)
#	else:
#		push_error("invalid mode: " + mode)


func _on_game_paused_changed(paused):
	if !paused && mark_to_update:
		set_mode()
		mark_to_update = false


func _on_settings_changed(key):
	if key == 'general.aim_mode':
		mode = Settings.get_aim_mode()
		mark_to_update = true

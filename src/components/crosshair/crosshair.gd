extends CanvasLayer

onready var sprite = $sprite
onready var parent = get_parent()

var mark_to_update_visible = false

func _ready():
	Global.connect("game_paused_changed", self, "_on_game_paused_changed")
	Global.connect("player_spawned", self, "_on_player_spawned")
	Settings.connect("changed", self, "_on_settings_changed")

	_update_sprite()
	sprite.modulate.a = 0
	
	# create on ready
	mark_to_update_visible = true
	sprite.modulate.a = 1
	_update_visible()


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _process(_delta):
	if InputSource.source == InputSource.KEYBOARD:
		sprite.global_position = get_viewport().get_mouse_position()
	else:
		if parent.input_controller.aim_direction:
			var position = parent.get_global_transform_with_canvas().origin
			sprite.global_position = position + parent.input_controller.aim_direction * 45


func show():
	visible = true
	sprite.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func hide():
	sprite.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _update_sprite():
	var data = Settings.get_crosshair()
	sprite.texture = load("res://assets/input/crosshair/crosshair%s.png" % [data.image_index])
	sprite.modulate = Color(data.color)
	sprite.scale = Vector2(data.scale, data.scale)
	sprite.material.set_shader_param('add_border', data.outline)
	sprite.material.set_shader_param('border_width', data.outline_size)


func _on_game_paused_changed(_paused):
	_update_visible()


func _update_visible():
	if !visible && !mark_to_update_visible:
		return
	if !Global.player.is_alive():
		hide()
		return
	if is_inside_tree() && get_tree().paused:
		hide()
	else:
		show()
	mark_to_update_visible = false


func _on_player_spawned():
	sprite.modulate.a = 1
	_update_visible()


func _on_settings_changed(key):
	if key == 'general.crosshair':
		_update_sprite()
	

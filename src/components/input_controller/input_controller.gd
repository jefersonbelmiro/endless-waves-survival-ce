extends Node

var direction = Vector2.RIGHT
var aim_direction = Vector2.RIGHT
var aim_mode := 'direction'
var joypad_deadzone = 0.35
var joystick_button_direction
var joystick_button_aim_direction

var last_direction := Vector2.RIGHT
var last_aim_direction := Vector2.RIGHT
var current_aim_direction_axis := Vector2.RIGHT
var target_aim_direction_axis := Vector2()
var aim_directon_ticks := 10.0
var aim_direction_tick := 1
var target_aim_elapsed := 0.0
var target_aim_delay := 0.15
var with_aim_direction = false

func _ready():
	if Global.has_touchscreen():
		joystick_button_direction = Global.create_joystick_button()
		add_child(joystick_button_direction)
		if with_aim_direction:
			show_joystick_aim_direction()


func _process(delta):
	direction = Vector2.ZERO
	aim_direction = Vector2.ZERO
	_update_direction()
	_update_aim_direction(delta)

	
func _update_direction():
	if InputSource.source == InputSource.JOYPAD:
		direction = _get_direction_joy_axis()
	elif InputSource.source == InputSource.KEYBOARD:
		direction = _get_direction_key_axis()
	elif InputSource.source == InputSource.TOUCH:
		direction = _get_direction_touch_axis()


func _update_aim_direction(delta: float):
	if !with_aim_direction:
		return
	var value: Vector2
	if InputSource.source == InputSource.JOYPAD:
		if aim_mode == 'crosshair':
			value = _get_aim_direction_joy_axis()
		else:
			value = direction if direction else last_direction
	elif InputSource.source == InputSource.KEYBOARD:
		if aim_mode == 'crosshair':
			value = _get_aim_direction_mouse_axis()
		else:
			value = _get_aim_direction_key_axis(delta)
	elif InputSource.source == InputSource.TOUCH:
		if aim_mode == 'crosshair':
			value = _get_aim_direction_touch_axis()
		else:
			value = direction if direction else last_direction
	if value:
		last_aim_direction = value
	if direction:
		last_direction = direction
	aim_direction = value if value else last_aim_direction


func get_direction():
	return direction


func get_aim_direction():
	return aim_direction


func toggle_joystick_button_aim_direction():
	if aim_mode == 'direction' && is_instance_valid(joystick_button_aim_direction):
		joystick_button_aim_direction.queue_free()
		joystick_button_direction.screen_dead_zone = joystick_button_direction.SCREEN_DEAD_ZONE.NONE
	if aim_mode == 'crosshair' && !is_instance_valid(joystick_button_aim_direction):
		show_joystick_aim_direction()


func show_joystick_aim_direction():
	if is_instance_valid(joystick_button_aim_direction):
		return
	joystick_button_aim_direction = Global.create_joystick_button()
	joystick_button_aim_direction.screen_dead_zone = joystick_button_aim_direction.SCREEN_DEAD_ZONE.RIGHT
	add_child(joystick_button_aim_direction)

	joystick_button_direction.screen_dead_zone = joystick_button_direction.SCREEN_DEAD_ZONE.LEFT


func _get_direction_joy_axis():
	var joy_axis = Vector2(
		Input.get_joy_axis(Global.session.controller_device, JOY_AXIS_0), 
		Input.get_joy_axis(Global.session.controller_device, JOY_AXIS_1)
	)
	if joy_axis.length() < 0.5:
		return Vector2.ZERO
	return joy_axis.normalized()


func _get_aim_direction_joy_axis():
	var joy_axis = Vector2(
		Input.get_joy_axis(Global.session.controller_device, JOY_AXIS_2), 
		Input.get_joy_axis(Global.session.controller_device, JOY_AXIS_3)
	)
	if joy_axis.length() < 0.5:
		return Vector2.ZERO
	return joy_axis.normalized()


func _get_direction_key_axis():
	var x = 0
	var y = 0
	if Input.is_action_pressed("move_right"): x = 1
	elif Input.is_action_pressed("move_left"): x = -1
	if Input.is_action_pressed("move_down"): y = 1
	elif Input.is_action_pressed("move_up"): y = -1
	# var x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	# var y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	var axis = Vector2(x, y)
	return axis.normalized()


func _get_aim_direction_key_axis(delta, tween = true):
	var x_pressed = Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left")
	var y_pressed = Input.is_action_pressed("move_down") || Input.is_action_pressed("move_up")
	var just_pressed = Input.is_action_just_pressed("move_right") || Input.is_action_just_pressed("move_left") || Input.is_action_just_pressed("move_down") || Input.is_action_just_pressed("move_up")

	if just_pressed || (x_pressed && y_pressed):
		target_aim_direction_axis = direction
		aim_direction_tick = 1
		target_aim_elapsed = 0.0
	# reset adjacent vectors when one axe is pressed
	elif x_pressed || y_pressed:
		if tween && target_aim_elapsed >= target_aim_delay:
			if x_pressed && !y_pressed:
				target_aim_direction_axis = Vector2(direction.x, 0).normalized()
			elif y_pressed && !x_pressed:
				target_aim_direction_axis = Vector2(0, direction.y).normalized()
			aim_direction_tick = 1
			target_aim_elapsed = 0.0
		target_aim_elapsed += delta
	# corner case when turn change x axis are relead after left and right actons have pressed in same time
	elif target_aim_direction_axis.x != last_direction.x && target_aim_direction_axis.y == last_direction.y:
		if target_aim_elapsed >= target_aim_delay:
			target_aim_direction_axis.x = last_direction.x
			aim_direction_tick = 1
			target_aim_elapsed = 0.0
		target_aim_elapsed += delta

	# change current to target direction 
	if current_aim_direction_axis != target_aim_direction_axis:
		var tween_ticks = aim_directon_ticks/2.0 if x_pressed && y_pressed else aim_directon_ticks
		if !tween:
			current_aim_direction_axis = target_aim_direction_axis
		else:
			if aim_direction_tick > tween_ticks:
				aim_direction_tick = 1
				current_aim_direction_axis = target_aim_direction_axis
				return current_aim_direction_axis.normalized()

			var weight = aim_direction_tick / tween_ticks
			aim_direction_tick += 1
			current_aim_direction_axis = lerp(current_aim_direction_axis, target_aim_direction_axis, weight)
	
	return current_aim_direction_axis.normalized()


func _get_aim_direction_mouse_axis():
	return get_parent().global_position.direction_to(get_parent().get_global_mouse_position())


func _get_direction_touch_axis():
	if !joystick_button_direction:
		return Vector2.ZERO
	return joystick_button_direction.get_value()


func _get_aim_direction_touch_axis():
	if !joystick_button_aim_direction:
		return _get_direction_touch_axis()
	return joystick_button_aim_direction.get_value()


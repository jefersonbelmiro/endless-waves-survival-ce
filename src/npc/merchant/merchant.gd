extends TargetBase

var target_position: Vector2

onready var input_icon = $input_icon

func _ready():
	var timer_node = Timer.new()
	timer_node.wait_time = 1.5
	timer_node.autostart = true
	timer_node.connect("timeout", self, "_find_random_position")
	add_child(timer_node)

	# disable/enable input handler
	set_process_input(!Global.is_mobile())
	# change area for non mobile plataforms
	$action_area/collision_shape_2d.shape.radius = 22 if !Global.is_mobile() else 11


func _input(event):
	if input_icon.visible && event.is_action_pressed("ui_action_active"):
		_open()


func _process(_delta):
	if target_position:
		var distance = target_position - global_position
		direction = distance.normalized()
		if distance.length() < 5:
			target_position = Vector2.ZERO
			direction = Vector2.ZERO

	if direction:
		state = STATES.WALK
		velocity = direction * stats.move_speed
	else:
		state = STATES.IDLE
		velocity = Vector2.ZERO


func _find_random_position():
	var safe_it = 100
	while safe_it > 0:
		var direction = Vector2.ONE.rotated(deg2rad(randi() % 360)).normalized()
		var final_position = global_position + direction * 15
		if !Global.map.spawn_bounds_has_point(final_position):
			continue
		else:
			target_position = final_position
			break


func _open():
	Global.hud.backpack_edit_popup.open({ use_player_backpack = true })
	Global.hud.backpack_edit_popup.connect("hide", self, "_on_backpack_edit_popup_hide", [], CONNECT_ONESHOT)
	Global.set_paused(true)


func _on_action_area_body_entered(body):
	if body != Global.player:
		return
	if Global.is_mobile():
		_open()
	else:
		input_icon.show()


func _on_backpack_edit_popup_hide():
	Global.set_paused(false)


func _on_action_area_body_exited(body):
	if body != Global.player || !input_icon.visible:
		return
	input_icon.hide()

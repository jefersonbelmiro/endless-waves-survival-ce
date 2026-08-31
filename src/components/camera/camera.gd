extends Camera2D

var target_position: Vector2
var move_speed = 150
var follow_player =  true

var bound_margins = { top = 30, right = 30, bottom = 30, left = 30, }

var _has_boundaries: bool

func _ready():
	set_as_toplevel(true)
	Settings.connect("changed", self, "_on_settings_changed")
	_set_zoom()


func _physics_process(delta):
	if target_position:
		var distance = target_position - global_position
		global_position += distance.normalized() * move_speed * delta
		if distance.length() < 5:
			global_position = target_position
			target_position = Vector2.ZERO
	elif follow_player:
		if !_has_boundaries:
			global_position = Global.player.global_position
		else:
			if limit_top != -10000000:
				global_position.y = Global.player.global_position.y
			if limit_left != -10000000:
				global_position.x = Global.player.global_position.x


func reset():
	_set_zoom()


func remove_bounds():
	limit_left = -10000000
	limit_right = 10000000
	limit_top = -10000000
	limit_bottom = 10000000


func move_to(position: Vector2, speed = 150):
	target_position = position
	move_speed = speed

	global_position = get_camera_screen_center()
	remove_bounds()


func set_bound_margins(margins: Dictionary):
	bound_margins = FP.patch_dictionary(bound_margins, margins)


func _set_zoom():
	var camera_zoom = clamp(1 + Settings.get_camera_zoom() * -1, 0.75, 2)
	zoom = Vector2(camera_zoom, camera_zoom)
	set_bounds()
	

func set_bounds():
	var view_size = get_viewport_rect().size
	var bounds = Global.map.get_camera_bounds(zoom)
	_has_boundaries = !!bounds

	if !bounds || bounds.size.x / zoom.x <= view_size.x - bound_margins.left - bound_margins.right:
		limit_left = -10000000
		limit_right = 10000000
		if bounds:
			global_position.x = bounds.get_center().x
	else:
		limit_left = bounds.position.x - bound_margins.left
		limit_right = bounds.end.x + bound_margins.right

	if !bounds || bounds.size.y / zoom.y <= view_size.y - bound_margins.top - bound_margins.bottom:
		limit_top = -10000000
		limit_bottom = 10000000
		if bounds:
			global_position.y = bounds.get_center().y
	else:
		limit_top = bounds.position.y - bound_margins.top
		limit_bottom = bounds.end.y + bound_margins.bottom


func _on_settings_changed(key: String):
	if key == 'general.camera_zoom':
		_set_zoom()

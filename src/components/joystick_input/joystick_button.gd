extends CanvasLayer

enum SCREEN_DEAD_ZONE { NONE, LEFT, RIGHT }

export(SCREEN_DEAD_ZONE) var screen_dead_zone = SCREEN_DEAD_ZONE.NONE setget set_screen_dead_zone

var radius = Vector2(32, 32)
var boundary = 64
var ongoing_drag = -1
var return_accel = 20
var threshold = 10
var initial_position: Vector2

var dead_zone_rect: Rect2

onready var touch_screen_button = $container/node_container/touch_screen_button
onready var node_container = $container/node_container


func _ready():
	touch_screen_button.position = (Vector2(0, 0) - radius) - touch_screen_button.position
	node_container.hide()
	Global.connect("game_paused_changed", self, "_on_game_paused_changed")

	_on_screen_dead_zone_changed()
	

func _process(delta):
	if ongoing_drag == -1:
		var pos_difference = (Vector2(0, 0) - radius) - touch_screen_button.position
		touch_screen_button.position += pos_difference * return_accel * delta


func set_screen_dead_zone(value):
	screen_dead_zone = value
	if is_inside_tree():
		_on_screen_dead_zone_changed()


func get_button_pos():
	return touch_screen_button.position + radius


func _input(event):
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
		if !_valid_input(event):
			return

		if  ongoing_drag == -1:
			node_container.global_position = event.position
			node_container.show()
		
		var event_dist_from_centre = (event.position - node_container.global_position).length()

		if event_dist_from_centre <= boundary * touch_screen_button.global_scale.x or event.get_index() == ongoing_drag:
			touch_screen_button.set_global_position(event.position - radius * touch_screen_button.global_scale)

			if get_button_pos().length() > boundary:
				touch_screen_button.set_position( get_button_pos().normalized() * boundary - radius)

			ongoing_drag = event.get_index()

	if event is InputEventScreenTouch and !event.is_pressed() and event.get_index() == ongoing_drag:
		ongoing_drag = -1
		node_container.hide()


func get_value():
	if get_button_pos().length() > threshold:
		return get_button_pos().normalized()
	return Vector2(0, 0)


func _valid_input(event: InputEvent):
	if !dead_zone_rect:
		return true
	if ongoing_drag == -1 && event is InputEventScreenDrag:
		return false
	return dead_zone_rect.has_point(event.position)


func _on_game_paused_changed(paused):
	if paused:
		node_container.hide()


func _on_screen_dead_zone_changed():
	var size_changed_connected = get_tree().get_root().is_connected("size_changed", self, "_on_size_changed")
	if screen_dead_zone != SCREEN_DEAD_ZONE.NONE:
		if !size_changed_connected:
			get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	else:
		dead_zone_rect = Rect2()
		if size_changed_connected:
			get_tree().get_root().disconnect("size_changed", self, "_on_size_changed")
	_update_dead_zone_rect()


func _update_dead_zone_rect():
	var view_rect = node_container.get_viewport_rect()
	if screen_dead_zone == SCREEN_DEAD_ZONE.LEFT:
		dead_zone_rect = view_rect.grow_individual(0, 0, -view_rect.size.x/2, 0)
	elif screen_dead_zone == SCREEN_DEAD_ZONE.RIGHT:
		dead_zone_rect = view_rect.grow_individual(-view_rect.size.x/2, 0, 0, 0)
	else:
		dead_zone_rect = Rect2()
	

func _on_size_changed():
	_update_dead_zone_rect()



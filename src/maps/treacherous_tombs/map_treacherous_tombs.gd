extends MapBase

const room_manager_class = preload("res://src/maps/treacherous_tombs/classes/room_manager.gd")
const tier_manager_class = preload("res://src/maps/treacherous_tombs/classes/tier_manager.gd")

var room_manager
var tier_manager

onready var start_position = $start_position
onready var transition_overlayer_bg = $transition_overlayer/bg

func _ready():
	randomize()
	room_manager = room_manager_class.new(self)
	tier_manager = tier_manager_class.new(self, room_manager)
	
	Global.connect("objective_status_changed", self, "_on_objective_status_changed")

	room_manager.connect("door_entered", self, "_on_door_entered")
	_set_systems()


func get_camera_bounds(zoom: Vector2):
	var bounds = get_bounds()
	bounds.position += Vector2(8 * zoom.x, -8)
	return bounds


func clear_systems():
	event_system.clear({ keep_rates = room_manager.current_room_index >= 13 })
	drop_system.stop()


func _on_door_entered(_door, room):
	if room.data.id == 'chest':
		clear_systems()
	
	# set player in spawn state to not move
	Global.player.state = Global.player.STATES.SPAWNING
	Global.player.velocity = Vector2.ZERO

	var upgrade_popup_about_to_show = false
	if !Global.hud.upgrade_popup.open_timer.is_stopped():
		upgrade_popup_about_to_show = true
		Global.hud.upgrade_popup.open_timer.stop()

	var tween = _create_transition_fadein()
	tween.connect("finished", self, "_on_door_transition_ended", [upgrade_popup_about_to_show])


func _on_door_transition_ended(upgrade_popup_about_to_show: bool):
	_create_transition_fadeout() 
	Global.player.state = Global.player.STATES.IDLE
	if upgrade_popup_about_to_show:
		Global.hud.upgrade_popup.open_timer.start()
	_update_systems()


func _set_systems():
	var tier_data = tier_manager.process()
	event_system.events = tier_data.events
	objective_system.objectives = tier_data.objectives
	clear_spawn_data()
	set_all_spawn_data(tier_data.spawn_data)

	room_manager.next_room_data = tier_data.room 
	room_manager.create_next_room()
	safe_zone = tier_data.room.id == 'chest' || tier_data.room.id == 'shop'


func _update_systems():
	_set_systems()
	objective_system.start()
	event_system.start()
	drop_system.start()


func _create_transition_fadein():
	transition_overlayer_bg.show()
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(transition_overlayer_bg, 'modulate:a', 1.0, 0.50)
	return tween


func _create_transition_fadeout():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(transition_overlayer_bg, 'modulate:a', 0.0, 0.50)
	tween.connect("finished", transition_overlayer_bg, "hide")
	return tween


func _on_objective_status_changed(victory):
	# when victory, dont have rooms, all rooms is clompleted
	if victory:
		return
	var value
	if data.mode == Global.MAP_MODES.OBJECTIVES:
		value = "%s/%s" % [room_manager.current_room_index + 1, room_manager.total_rooms]
	else:
		value = room_manager.current_room_index + 1
	Global.hud.objective_status_popup.additional_rows = [
		{ label = "ROOMS", value = value }
	]

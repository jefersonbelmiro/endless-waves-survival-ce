extends Reference

signal door_entered(door, room)

const room_dynamic_scene = preload("res://src/maps/treacherous_tombs/rooms/dynamic/room_treacherous_tombs_dynamic.tscn")

const ROOMS_TYPES = { DYNAMIC = 'DYNAMIC', SCENE = 'SCENE' }
const ROOMS_DATA = {
	small_square = {
		id = 'small_square',
		size = Vector2(20, 12),
	},
	big_square = {
		id = 'big_square',
		size = Vector2(24, 17),
	},
	horizontal = {
		id = 'horizontal',
		size = Vector2(12, 30),
	},
	chest = {
		id = "chest",
		size = Vector2(10, 8),
	},
	shop = {
		id = "shop",
		size = Vector2(10, 8),
	}
}

var current_room: Node2D
var total_rooms = 15
var current_room_index = 0
var next_room_data
var map

func _init(map_):
	map = map_
	randomize()

	total_rooms *= map.data.level
	_create_rooms_label()

	# disconect on current map and connect to this class
	if map.objective_system.is_connected("completed", map, "_on_objectives_completed"):
		map.objective_system.disconnect("completed", map, "_on_objectives_completed")
	if !map.objective_system.is_connected("completed", self, "_on_objectives_completed"):
		map.objective_system.connect("completed", self, "_on_objectives_completed", [], CONNECT_DEFERRED)

	Settings.connect("language_changed", self, "_on_language_changed")


func create_next_room():
	if current_room:
		current_room.queue_free()

	var room_data = _create_room_data()
	current_room = _create_room(room_data)

	_on_update_room()

	Global.kill_all_drops()
	Global.kill_all_summons()
	Global.remove_all_floor_nodes()
	Global.remove_all_non_player_entities()

	_update_rooms_label()


func get_room_data(id: String):
	return ROOMS_DATA[id]


func _create_room(data):
	var node = room_dynamic_scene.instance()
	node.data = data.value
	node.connect("door_entered", self, "_on_door_entered")
	map.add_child(node)
	return node


func _create_door_data(id: String, size: Vector2):
	match id:
		"gateway": return { id = id, position = Vector2(size.x / 2 - 2, 0) }
		"shop": return { id = id, position = Vector2(size.x / 2 - 2, 0) }
		"chest": return { id = id, position = Vector2(size.x / 2 - 2, 0) }


func _create_room_data():
	var doors_data = []
	var is_last_room = false if map.data.mode == Global.MAP_MODES.ENDLESS else current_room_index + 1 >= total_rooms
	if !is_last_room:
		doors_data.append(_create_door_data("gateway", next_room_data.size))

	return {
		type = ROOMS_TYPES.DYNAMIC,
		value = {
			id = next_room_data.id,
			size = next_room_data.size,
			doors = doors_data,
		}
	}


func _on_door_entered(door, room):
	if room.data.id != 'chest':
		current_room_index += 1
	emit_signal("door_entered", door, room)


func _on_update_room():
	# update bounds
	var tile_bounds = current_room.get_node_or_null("tile_bounds")
	if tile_bounds:
		map._bounds = map.calculate_bounds(tile_bounds)
		map._spawn_bounds = map._bounds.grow(-10).grow_individual(0, 0, 0, -40)

	var start_position = Vector2(current_room.data.size.x * 8 + 16, current_room.data.size.y * 16) 
	var is_last_room = false if map.data.mode == Global.MAP_MODES.ENDLESS else current_room_index + 1 >= total_rooms

	# update start position
	# last room, set start position to center of room
	# update start because portal use this position when dont have portal_position node
	if is_last_room:
		map.start_position.global_position = current_room.global_position 
		map.start_position.global_position += current_room.data.size * 16 * 0.5 + Vector2(16, 16)
	else:
		map.start_position.global_position = start_position
	Global.player.global_position = start_position

	var camera = Global.player.camera if Global.player.camera else Global.player.get_node("camera")
	if camera.is_inside_tree():
		camera.set_bounds()


func _on_objectives_completed():
	map.clear_systems()
	map.safe_zone = true

	Global.kill_all_enemies()
	if current_room_index + 1 >= total_rooms && map.data.mode == Global.MAP_MODES.OBJECTIVES:
		Global.emit_signal("objectives_completed")
	else:
		Global.collect_all_coins_experience()
		current_room.open_gates()


func _create_rooms_label():
	var rooms_label = RichTextLabel.new()
	rooms_label.bbcode_enabled = true
	rooms_label.scroll_active = false
	rooms_label.fit_content_height = true
	rooms_label.rect_min_size = Vector2(200, 16)
	rooms_label.size_flags_horizontal = rooms_label.SIZE_EXPAND_FILL
	Global.hud_objectives_container.get_parent().add_child(rooms_label)
	Global.hud_objectives_container.get_parent().move_child(rooms_label, 0)
	_update_rooms_label()


func _update_rooms_label():
	if current_room && (current_room.data.id == 'chest' || current_room.data.id == 'shop'):
		Global.hud_objectives_container.get_parent().hide()
		return

	Global.hud_objectives_container.get_parent().show()
	var rooms_label = Global.hud_objectives_container.get_parent().get_child(0)
	if map.data.mode == Global.MAP_MODES.OBJECTIVES:
		rooms_label.bbcode_text = "%s: [color=grey]%s/%s[/color]" % [tr("ROOMS"), current_room_index + 1, total_rooms]
	else:
		rooms_label.bbcode_text = "%s: [color=grey]%s[/color]" % [tr("ROOM"), current_room_index + 1]


func _on_language_changed():
	_update_rooms_label()



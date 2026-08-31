extends MapBase

const sector_manager_class = preload("res://src/maps/desert/classes/sector_manager.gd")
const event_manager_class = preload("res://src/maps/desert/classes/event_manager.gd")

const SECTOR_SIZE = Vector2(500, 500)
const SECTOR_UPDATE_TIME = 1.0

var spawn_min_range = 50 
var spawn_max_range = 100

var sector_manger
var event_manager

onready var start_position = $start_position

func _ready():
	randomize()
	VisualServer.set_default_clear_color(Color('#381f1f'))
	sector_manger = sector_manager_class.new({ map = self, size = SECTOR_SIZE, update_time = SECTOR_UPDATE_TIME })
	event_manager = event_manager_class.new(self)

	sector_manger.init()
	event_manager.init()

	var targets_out_of_bounds_timer = Timer.new()
	targets_out_of_bounds_timer.autostart = true
	targets_out_of_bounds_timer.wait_time = 5.0
	targets_out_of_bounds_timer.connect("timeout", self, "_on_targets_out_of_bounds_timeout")
	add_child(targets_out_of_bounds_timer)

	var entities_out_of_bounds_timer = Timer.new()
	entities_out_of_bounds_timer.autostart = true
	entities_out_of_bounds_timer.wait_time = 1.0
	entities_out_of_bounds_timer.connect("timeout", self, "_on_entities_out_of_bounds_timeout")
	add_child(entities_out_of_bounds_timer)


func _process(_delta):
	_bounds = Global.get_viewport_bounds().grow(15)
	_spawn_bounds = _bounds


func get_camera_bounds(_zoom: Vector2):
	return null


# set position to targets outside bounds
func _on_targets_out_of_bounds_timeout():
	var nodes = Targets.get_outside_rect(_bounds.grow(spawn_max_range))
	var teleport_nodes = []
	for index in nodes.size():
		var node = nodes[index]
		if node.is_in_group("bosses"):
			continue
		elif node.is_in_group("body_parts"):
			continue
		elif node.is_in_group("mob_parent") || node.is_in_group("mob_child"):
			continue
		elif 'id' in node && (node.id.begins_with("centipede") || node.id.begins_with("serpent")):
			continue
		teleport_nodes.append(node)

	if teleport_nodes.size():
		set_positions_outside_map_bounds(teleport_nodes, { min_range = spawn_min_range, max_range = spawn_max_range })


# remove all spell outside bounds
func _on_entities_out_of_bounds_timeout():
	var bounds = _spawn_bounds.grow(spawn_max_range + 25)
	for index in Global.entity_container.get_child_count():
		var node = Global.entity_container.get_child(index)
		if !is_instance_valid(node) || node == Global.player:
			continue
		if node.is_in_group("targets") || node.is_in_group("drops"):
			continue
		elif node.is_in_group("mob_parent") || node.is_in_group("mob_child"):
			continue
		if node.is_in_group("portal"):
			continue
		if !bounds.has_point(node.global_position):
			node.queue_free()


func _on_objectives_completed():
	start_position.global_position = sector_manger.current_sector.get_center_position()
	._on_objectives_completed()

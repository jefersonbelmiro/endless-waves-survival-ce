extends Reference

var map

const sector_scene = preload("res://src/maps/desert/sector/sector.tscn")

const LINK_VECTOR = {
	top = Vector2(0, -1), # north
	top_right = Vector2(1, -1), # northeast
	right = Vector2(1, 0), # east
	bottom_right = Vector2(1, 1), # southeast
	bottom = Vector2(0, 1), # south
	bottom_left = Vector2(-1, 1), # southwest
	left = Vector2(-1, 0), # west
	top_left = Vector2(-1, -1), # northwest
}

var size = Vector2(500, 500)
var update_time = 1.0

var sectors = {}
var current_sector: Node2D


func _init(data: Dictionary):
	for key in data.keys():
		self[key] = data[key]


func init():
	randomize()

	# create start sector from start position, player dont create yet
	var position = map.get_node("start_position").global_position - size/2
	current_sector = _create_sector(position)
	_create_links(current_sector)

	var check_sector_timer = Timer.new()
	check_sector_timer.autostart = true
	check_sector_timer.wait_time = update_time
	check_sector_timer.connect("timeout", self, "_on_check_sector_timeout")
	map.add_child(check_sector_timer)


func _on_check_sector_timeout():
	if current_sector.rect.has_point(Global.player.position):
		return
	for position_key in current_sector.links.keys():
		var node = current_sector.links[position_key]
		if is_instance_valid(node) && node.rect.has_point(Global.player.global_position):
			current_sector = node
			_create_links(current_sector)
			_remove_fair_sectors(current_sector)
			return

	# find closest sector, 
	var current_distance = 99999
	var closest_sector
	for position_key in current_sector.links.keys():
		var node = current_sector.links[position_key]
		if !is_instance_valid(node):
			continue
		var distance = (node.global_position + node.size/2).distance_to(Global.player.global_position)
		if distance < node.size.length() && distance < current_distance:
			current_distance = distance
			closest_sector = node
	
	if closest_sector:
		current_sector = closest_sector
		_create_links(current_sector)
		_remove_fair_sectors(current_sector)
		return  

	# distance length great than sector size, recreate all sector
	_remove_all_sectors()
	current_sector = _create_sector(Global.player.global_position - size/2)
	_create_links(current_sector)


func _remove_all_sectors():
	for node in sectors.keys():
		if is_instance_valid(node):
			node.queue_free()
	sectors = {}


func _remove_fair_sectors(center_sector):
	var links = { center_sector: true }
	for position_key in center_sector.links.keys():
		var node = center_sector.links[position_key]
		links[node] = true
	for node in sectors.keys():
		if !links.has(node):
			node.queue_free()
			sectors.erase(node)


func _create_sector(position):
	var node = sector_scene.instance()
	node.size = size
	node.global_position = position
	node.rect = Rect2(position, size)
	sectors[node] = true
	map.add_child(node)
	return node


func _create_links(sector: Node2D):
	for position_key in LINK_VECTOR.keys():
		var link_node = sector.links[position_key]
		if !is_instance_valid(link_node):
			var position = sector.global_position + LINK_VECTOR[position_key] * sector.size 
			var node = _create_sector(position)
			sector.links[position_key] = node

	# fix link connections
	for position_key in LINK_VECTOR.keys():
		var link_node = sector.links[position_key]
		match position_key:
			'top':
				link_node.links.bottom = sector
				link_node.links.left = sector.links.top_left
				link_node.links.right = sector.links.top_right
			'top_right':
				link_node.links.bottom_left = sector
				link_node.links.left = sector.links.top
				link_node.links.bottom = sector.links.right
			'right':
				link_node.links.left = sector
				link_node.links.top = sector.links.top_right
				link_node.links.bottom = sector.links.bottom_right
			'bottom_right':
				link_node.links.top_left = sector
				link_node.links.top = sector.links.right
				link_node.links.left = sector.links.bottom
			'bottom':
				link_node.links.top = sector
				link_node.links.left = sector.links.bottom_left
				link_node.links.right = sector.links.bottom_right
			'bottom_left':
				link_node.links.top_right = sector
				link_node.links.right = sector.links.bottom
				link_node.links.top = sector.links.left
			'left':
				link_node.links.right = sector
				link_node.links.top = sector.links.top_left
				link_node.links.bottom = sector.links.bottom_left
			'top_left':
				link_node.links.bottom_right = sector
				link_node.links.right = sector.links.top
				link_node.links.bottom = sector.links.left



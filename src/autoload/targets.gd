extends Node

var nodes = []


func _process(_delta):
	nodes = get_tree().get_nodes_in_group('targets')


func get_closest_target(position_find: Vector2, ignore = [], distance: float = 0):
	if !nodes.size():
		return null
	var current_target = null
	var current_dist = 9999
	for index in nodes.size():
		if !is_valid(nodes[index]):
			continue
		if ignore.has(nodes[index]):
			continue
		if distance && !_in_range(nodes[index], position_find, distance):
			continue
		var dist = position_find.distance_to(nodes[index].global_position)
		if current_dist > dist:
			current_dist = dist
			current_target = nodes[index]
	return current_target


func get_closest_targets(position_find: Vector2, size = 1, ignore = [], distance: float = 0):
	if !nodes.size():
		return []
	var result_data = {}
	for index in nodes.size():
		var node = nodes[index]
		if !is_valid(node):
			continue
		if ignore.has(node):
			continue
		var current_dist = position_find.distance_to(node.global_position)
		if distance && current_dist > distance:
			continue
		result_data[node] = {
			ref = node,
			distance = current_dist
		}
	var values = result_data.values()
	if values.size() == 1:
		return [values[0].ref]
	var result = []
	if values.size() > 1:
		values.sort_custom(self, "_sort_by_distance")
		for index in values.size():
			result.append(values[index].ref)
			if result.size() >= size:
				break
	return result


func get_random_targets(position_find: Vector2, ignore = [], size = 1, distance: float = 0):
	var result = []
	for index in nodes.size():
		var target = nodes[randi() % nodes.size()] 
		if !is_valid(target):
			continue
		if ignore.has(target):
			continue
		if distance > 0 && position_find.distance_to(target.global_position) > distance:
			continue
		if !result.has(target):
			result.append(target)
		if result.size() == size:
			return result
	return result


func get_random_target(position_find: Vector2, ignore = [], distance: float = 0):
	if !nodes.size():
		return null
	var attempts = 20
	while attempts >= 0:
		attempts -= 1
		var target = nodes[randi() % nodes.size()]
		if !is_valid(target):
			continue
		if ignore.has(target):
			continue
		if distance > 0 && position_find.distance_to(target.global_position) > distance:
			continue
		return target
	return null


func get_first_target_in_group(group_name):
	var group = get_tree().get_nodes_in_group(group_name)
	if group.size():
		return group[0]
	return null


func get_in_rect(rect: Rect2):
	var result = []
	for index in Targets.nodes.size():
		var node = Targets.nodes[index]
		if is_valid(node) && rect.has_point(node.global_position):
			result.append(node)
	return result


func get_outside_rect(rect: Rect2):
	var result = []
	for index in Targets.nodes.size():
		var node = Targets.nodes[index]
		if is_valid(node) && !rect.has_point(node.global_position):
			result.append(node)
	return result


func is_valid(node):
	if !is_instance_valid(node):
		return false
	if node.is_in_group("body_parts"):
		node = node.get_parent()
	if 'state' in node && !node.is_alive():
		return false
	if node.hurt_box_collision.disabled:
		return false
	return true


func in_range(target, position_find: Vector2, distance: float = 0):
	if !is_valid(target):
		return false
	return _in_range(target, position_find, distance)


func in_area(target, position_find: Vector2, area: float = 0):
	if !is_valid(target):
		return false
	return _in_range(target, position_find, area / 2.0)


func _sort_by_distance(a, b):
	return b.distance > a.distance


func _in_range(target, position_find: Vector2, distance: float = 0):
	var target_position = target.global_position
	var body_radius = 0
	if 'collision' in target:
		body_radius = target.collision.shape.radius
	if distance > 0 && position_find.distance_to(target_position) > distance + body_radius:
		return false
	return true



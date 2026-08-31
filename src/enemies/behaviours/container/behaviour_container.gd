extends Node
class_name BehaviourContainer

export var connect_modifiers = true

var behaviours = {}
var groups = {
	default = Group.new(),
	buff = Group.new(),
	move = Group.new(),
	attack = Group.new(),
	debuff = Group.new(),
}
var ref_count = {}

var process_queue = {}
var process_queue_order = []
var process_queue_mark_for_update = false
var group_sort_order = {
	buff = 0,
	move = 1,
	attack = 2,
	debuff = 3,
	default = 4,
}


func _ready():
	if connect_modifiers:
		var stats = get_parent().get_node_or_null('stats')
		if !stats: return push_error("not found stats node")
		stats.connect('modifier_added', self, '_on_stats_modifier_added')
		stats.connect('modifier_removed', self, '_on_stats_modifier_removed')


func _process(delta):
	if process_queue_mark_for_update:
		_update_process_queue()
	for index in process_queue_order.size():
		var id = process_queue_order[index]
		behaviours[id]._process(delta)


func has(id: String):
	return behaviours.has(id)


func get(id: String):
	return behaviours.get(id)


func add_modifier_behaviour(modifier_id: String, data = null):
	var behaviour_id = _get_modifier_handler(modifier_id)
	return add(behaviour_id, data)


func set_data(id: String, data = null):
	if !behaviours.has(id) || !data:
		return
	for key in data:
		if !key in behaviours[id]:
			push_error("invalid behavior data key: " + key)
			continue
		behaviours[id][key] = data[key]


func add_once(id: String, data = null):
	if !behaviours.has(id):
		return add(id, data)
	set_data(id, data)
	return behaviours.get(id)


func set(id: String, behaviour, data = null):
	behaviour.id = id
	behaviour.container = self
	behaviour.host = get_parent()
	behaviours[id] = behaviour
	ref_count[id] = 1

	set_data(id, data)

	groups.get(behaviour.group_id).add(behaviour, !data || !'disabled' in data)

	if behaviour.has_method('_ready'):
		behaviour._ready()
		
	if behaviour.has_method('_process'):
		process_queue[id] = true
		process_queue_mark_for_update = true


func add(id: String, data = null):
	if behaviours.has(id):
		ref_count[id] += 1
		set_data(id, data)
		return behaviours.get(id)
	var behaviour = _create_handler(id)
	if !behaviour:
		return null
	set(id, behaviour, data)
	return behaviour


func remove(id: String):
	if !behaviours.has(id):
		return
	var behaviour = behaviours[id]
	if behaviour.has_method('_exit_tree'):
		behaviour._exit_tree()

	ref_count[id] -= 1
	if ref_count[id] <= 0:
		groups[behaviour.group_id].remove(behaviour)
		behaviours.erase(id)
		if process_queue.has(id):
			process_queue.erase(id)
			process_queue_mark_for_update = true
		ref_count.erase(id)


func remove_modifier_behaviour(modifier_id: String):
	var behaviour_id = _get_modifier_handler(modifier_id)
	remove(behaviour_id)


func has_group(group_id):
	return groups.get(group_id).data.size() > 0


func disabled_group(group_id):
	if !groups.has(group_id):
		return false
	return groups.get(group_id).disabled


func disable_group(group_id, ignore = null):
	if !groups.has(group_id):
		return
	groups.get(group_id).disable(ignore)


func enable_group(group_id, ignore = null):
	if !groups.has(group_id):
		return
	groups.get(group_id).enable(ignore)


func _on_stats_modifier_added(modifier_data):
	if _has_modifier_handler(modifier_data.id):
		add_modifier_behaviour(modifier_data.id)


func _on_stats_modifier_removed(modifier_data):
	if _has_modifier_handler(modifier_data.id):
		remove_modifier_behaviour(modifier_data.id)


func _get_modifier_handler(modifier_id):
	return Global.behaviours_modifier.get(modifier_id)


func _has_modifier_handler(modifier_id):
	return Global.behaviours_modifier.has(modifier_id)


func _create_handler(id: String):
	if !Global.behaviours.has(id):
		push_error("Invalid behaviour id: " + id)
		return null
	return Global.behaviours[id].new()


func _update_process_queue():
	process_queue_order = process_queue.keys()
	process_queue_order.sort_custom(self, "_sort_process_queue")
	process_queue_mark_for_update = false


func _sort_process_queue(a_id, b_id):
	var a_sort = group_sort_order.get(behaviours.get(a_id).group_id)
	var b_sort = group_sort_order.get(behaviours.get(b_id).group_id)
	return b_sort > a_sort


class Group:
	var disabled = false
	var data = []

	func add(behaviour, update_disabled):
		if data.has(behaviour):
			return false
		if update_disabled && disabled:
			behaviour.disabled = true
		data.append(behaviour)
		return true


	func remove(behaviour):
		data.erase(behaviour)


	func disable(ignore = null):
		if !ignore || ignore.size() == 0:
			disabled = true
		for index in data.size():
			if ignore && ignore.has(data[index].id):
				continue
			data[index].disabled = true


	func enable(ignore = null):
		if !ignore || ignore.size() == 0:
			disabled = false
		for index in data.size():
			if ignore && ignore.has(data[index].id):
				continue
			data[index].disabled = false


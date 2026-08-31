extends Behaviour
class_name CallShieldFormationBehaviour

var move_speed: float = 150
var threshold: float = 5
var keep_formation = true
var size = 12
var cooldown: float = 4.0
var proc_chance: float = 0.8
var target_id: String

var _timer: float = 0
var _targets = []

func _init():
	group_id = "buff"
	_targets.resize(size)


func _process(delta):
	if disabled || !Global.player.is_alive():
		return

	_timer += delta
	if _timer > cooldown:
		_timer = 0
		if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
			_call()


func _call():
	var _slots = []

	for index in _targets.size():
		var node = _targets[index]
		if !node:
			_slots.append(index)
			continue

		if !is_instance_valid(node) || !node.is_alive():
			_slots.append(index)
			_targets[index] = null

	if _slots.size() == 0:
		return

	var nodes = host.get_tree().get_nodes_in_group("enemies")
	for index in nodes.size():
		var node = nodes[index]
		if !is_instance_valid(node) || node == host || !node.is_alive() || node.is_disabled():
			continue
		if _targets.has(node): 
			continue
		if target_id && node.id != target_id:
			continue
		if node.behaviour_container.has("shield_formation"):
			continue

		# another behaviour disable move
		# ignore to prevent conflict with multiple move behaviours
		if node.behaviour_container.groups.move.disabled:
			continue

		var slot_index = _slots[-1] 
		if _attach_behavior(node, slot_index):
			_slots.remove(_slots.size() - 1)
			_targets[slot_index] = node
		if _slots.size() <= 0:
			break


func _attach_behavior(node, slot_index):
	var target_position = Global.map.get_position_circle_index(slot_index, host.global_position, size, 40)
	if !target_position:
		return false
	var data = { 
		target_distance = target_position - host.global_position,
		target = host,
		move_speed = move_speed,
		threshold = threshold,
		keep_formation = keep_formation,
	}
	node.behaviour_container.add("shield_formation", data)
	return true


func _exit_tree():
	for index in _targets.size():
		var node = _targets[index]
		if !is_instance_valid(node) || !node.is_alive():
			continue
		node.behaviour_container.remove("shield_formation")
		node.behaviour_container.remove("shadow_chase_target")
		node.behaviour_container.enable_group("move")
			

extends Behaviour
class_name FindTargetBehaviour

var timer_node: Timer
var target_taunt: Node
var target_hit: Node
var target_hit_check_group = false

func _init():
	group_id = "default"


func _ready():
	host.stats.connect("hitted", self, "_on_stats_hitted")
	_find_target()


func _exit_tree():
	host.stats.disconnect("hitted", self, "_on_stats_hitted")


func _on_stats_hitted(result: Dictionary):
	if !'source_node' in result || !is_instance_valid(result.source_node) || !result.source_node.is_alive():
		return

	var hit_source = result.source_node

	# same target
	if host.target == hit_source:
		return

	if 'taunt' in result && (!is_instance_valid(target_taunt) || !target_taunt.is_alive()):
		target_taunt = hit_source

	# no damage
	if !'damage' in result || !result.damage:
		return
		
	# current target hit is valid
	if !is_instance_valid(target_taunt) && is_instance_valid(target_hit) && target_hit.is_alive():
		return

	target_hit = hit_source
	if is_instance_valid(target_taunt):
		target_hit = target_taunt

	if target_hit_check_group:
		var found_group = false
		for group in host.targets.keys():
			if hit_source.is_in_group(group):
				found_group = true
				break
		if !found_group:
			return

	_set_target(target_hit)


func _find_target():
	if is_instance_valid(target_taunt) && target_taunt.is_alive():
		host.target = target_taunt
		return
	if is_instance_valid(target_hit) && target_hit.is_alive():
		host.target = target_hit
		return

	var groups = host.targets.keys()
	var result = {}
	for group in groups:
		var nodes = host.get_tree().get_nodes_in_group(group)
		var options = host.targets[group]
		for index in nodes.size():
			var node = nodes[index]
			if !is_instance_valid(node) || ('state' in node && !node.is_alive()):
				continue
			if result.has(node):
				continue
			var distance = host.global_position.distance_to(node.global_position)
			if options.use_attack_range && distance > host.stats.attack_range:
				continue
			result[node] = {
				ref = node,
				distance = distance
			}

	var values = result.values()
	if result.size() > 1:
		values.sort_custom(self, "_sort_by_distance")
	if result.size() > 0:
		_set_target(values[0].ref)
	else:
		host.target = null
		Global.delay_func(self, "_find_target", 1.5)


func _set_target(node):
	if host.target == node:
		return
	host.target = node
	if node != Global.player && !node.stats.is_connected("deaded", self, "_find_target"):
		node.stats.connect("deaded", self, "_find_target", [], CONNECT_ONESHOT | CONNECT_DEFERRED)


func _sort_by_distance(a, b):
	return b.distance > a.distance



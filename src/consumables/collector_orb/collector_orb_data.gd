extends ConsumableData
class_name CollectorOrbData


func _init(data_apply: Dictionary).(data_apply):
	pass


# overwrite to not emit signals
func added(): pass
func removed(): pass


func apply_modifiers():
	var nodes = host.get_tree().get_nodes_in_group("drops")
	for index in nodes.size():
		var node = nodes[index]
		if !is_instance_valid(node):
			continue
		node.set_picker(host.parent, 3)
	host.remove_modifier(data.id)


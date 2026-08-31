extends Control


var spell_scene = preload("res://src/components/hud_slot/hud_slot.tscn")
var ultimate_scene = preload("res://src/components/hud_ultimate_slot/hud_ultimate_slot.tscn")

var slot_data = {
	autocast = {
		current_slot_index = 0,
		max_slot_index = 9
	},
	activated = {
		current_slot_index = 0,
		max_slot_index = 1
	}
}

onready var container_autocast = $container/autocast
onready var container_activated = $container/activated


func has_empty_slot():
	var activated = slot_data.activated.current_slot_index <= slot_data.autocast.max_slot_index 
	var autocast = slot_data.autocast.current_slot_index <= slot_data.autocast.max_slot_index 
	return activated || autocast


func has_activated():
	return slot_data.activated.current_slot_index > 0


func can_add(data):
	if data.cast_type == Global.SKILL_CAST_TYPE.ULTIMATE:
		return slot_data.activated.current_slot_index <= slot_data.activated.max_slot_index
	return slot_data.autocast.current_slot_index <= slot_data.autocast.max_slot_index
	
	
func release_slot(data):
	var node
	if 'type' in data && data.cast_type == Global.SKILL_CAST_TYPE.ULTIMATE:
		slot_data.activated.current_slot_index -= 1
		node = container_activated.get_node_or_null(data.id)
	else:
		slot_data.autocast.current_slot_index -= 1
		node = container_autocast.get_node_or_null(data.id)
	if node:
		node.queue_free()
	

func add_spell(data):
	if !can_add(data):
		return null
	
	var scene
	if data.cast_type == Global.SKILL_CAST_TYPE.ULTIMATE:
		slot_data.activated.current_slot_index += 1
		scene = ultimate_scene
	else:
		slot_data.autocast.current_slot_index += 1
		scene = spell_scene
	
	var node = scene.instance()
	node.name = data.id
	node.icon_texture = data.icon
	node.label_value = data.level  
	if data.cast_type == Global.SKILL_CAST_TYPE.ULTIMATE:
		node.card_id = data.id

		if data.id == 'dash':
			node.action_name = "cast_dash"
		else:
			# use second action when other skill is dash or has only one
			if Global.player.has_spell("dash") || container_activated.get_child_count() == 0:
				node.action_name = "cast_ultimate_1"
			else:
				node.action_name = "cast_ultimate_0"

		container_activated.add_child(node)
		if !container_activated.visible:
			container_activated.show()

		# move to first possion dash or second ultimate
		if data.id == 'dash' || !Global.player.has_spell("dash"): 
			container_activated.move_child(node, 0)
	else:
		container_autocast.add_child(node)
	return node


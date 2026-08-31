extends Control

var hud_slot_scene = preload("res://src/components/hud_slot/hud_slot.tscn")

export var empty_slot_color = Color('#6affffff')

onready var container = $container

var slot_data = {}

	
func release_slot(data):
	if slot_data.has(data.id):
		slot_data.get(data.id).call_deferred('queue_free')
	slot_data.erase(data.id)

	

func get_node_from_data(data):
	if !slot_data.has(data.id):
		return null
	return slot_data.get(data.id)


func add(data):
	if slot_data.has(data.id):
		return slot_data.get(data.id)
	var node = hud_slot_scene.instance()
	node.icon_texture = data.icon
	slot_data[data.id] = node
	container.call_deferred('add_child', node)
	return node


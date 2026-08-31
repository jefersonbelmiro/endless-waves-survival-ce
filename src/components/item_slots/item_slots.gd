extends Control

export var empty_slot_color = Color('#6affffff')

onready var container = $container


var current_slot_index = 0
var max_slot_index = 4
var slot_data = {}

func _ready():
	for index in container.get_child_count():
		var node = container.get_child(index)
		node.modulate = empty_slot_color
		node.get_node('cooldown').queue_free()
		node.get_node('texture_rect').hide()
		node.get_node('label').hide()


func has_empty_slot():
	return current_slot_index <= max_slot_index


func can_add(_data):
	return has_empty_slot()
	
	
func release_slot(data):
	slot_data.erase(data.id)
	current_slot_index -= 1
	var node_index = current_slot_index
		
	var node = container.get_child(node_index)
	node.get_node('texture_rect').hide()
	node.get_node('label').hide()
	node.modulate = empty_slot_color
	

func get_node_from_data(data):
	if !slot_data.has(data.id):
		return null
	return slot_data[data.id]


func add(data):
	if !can_add(data):
		return null

	var node_index = current_slot_index
	current_slot_index += 1
	
	var node = container.get_child(node_index)
	var texture_rect = node.get_node("texture_rect")
	var label = node.get_node("label")
	texture_rect.texture = data.icon
	texture_rect.show()
	label.text = str(data.level)  
	label.show()  
	node.modulate = Color(1, 1, 1)
	slot_data[data.id] = node
	return node


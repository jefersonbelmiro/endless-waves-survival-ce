extends Control

export var item_size = 20
export var h_separation = 4
export var center = true

var columns = 0

onready var scroll_container = $scroll_container
onready var margin_container = $scroll_container/margin_container
onready var grid_container = $scroll_container/margin_container/grid_container


func _ready():
	_update_grid()


func add_child(node: Node, legible_unique_name: bool = false):
	grid_container.add_child(node, legible_unique_name)
	
	
func get_node_or_null(path):
	return grid_container.get_node_or_null(path)


func get_child(index):
	return grid_container.get_child(index)


func clear():
	Global.node_remove_children(grid_container)


func get_child_count():
	return grid_container.get_child_count()


func _update_grid():
	columns = floor((rect_size.x - h_separation * 2) / (item_size + h_separation))
	var full_size = ((item_size + h_separation) * columns) - h_separation
	var width = rect_size.x - full_size

	# scroll_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	# scroll_container.margin_top = 4
	# scroll_container.margin_bottom = -4
	# margin_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	margin_container.set("custom_constants/margin_top", 2)
	margin_container.set("custom_constants/margin_bottom", 2)
	if center:
		margin_container.set("custom_constants/margin_left", width/2)
		margin_container.set("custom_constants/margin_right", -width/2)
	else:
		margin_container.set("custom_constants/margin_left", 2)
		margin_container.set("custom_constants/margin_right", -2)

	grid_container.set_columns(columns)
	grid_container.set('custom_constants/h_separation', h_separation)


func _on_grid_container_resized():
	if grid_container:
		_update_grid()

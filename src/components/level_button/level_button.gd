extends Control

export var current_level = 0 setget set_current_level
export var selected_color = Color("#d8da1a")
export var selected_border_color = Color("#70710b")

export var unselected_color = Color("#9b9b9b")
export var unselected_border_color = Color("#817d7d")

onready var container: Control = get_node("container")
onready var button: Control = $book_button


func set_current_level(level: int):
	current_level = level
	for index in $container.get_child_count():
		var column = $container.get_child(index)
		if index < current_level:
			column.get_node('bg').color = selected_color
			column.get_node('border').modulate = selected_border_color
		else:
			column.get_node('bg').color = unselected_color
			column.get_node('border').modulate = unselected_border_color

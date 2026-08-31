extends Node2D

onready var parent = get_parent()

func _process(_delta: float):
	rotation = parent.input_controller.aim_direction.angle() 



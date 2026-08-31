extends Area2D

export var collision_radius = 10
export var disabled: bool = true setget set_disabled

onready var collision = $collision_shape_2d
onready var collision_shape = $collision_shape_2d.shape


func _ready():
	collision_shape.radius = collision_radius
	collision.disabled = disabled


func set_disabled(value: bool):
	disabled = value
	if collision:
		collision.set_deferred('disabled', disabled)

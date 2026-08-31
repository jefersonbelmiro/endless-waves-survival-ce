extends Node2D

export var amount = 30

onready var particles = $particles_2d

func _ready():
	particles.amount = amount

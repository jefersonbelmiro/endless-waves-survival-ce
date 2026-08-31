extends Node

onready var parent = get_parent()
onready var stats: Stats = parent.stats
onready var behaviour_container: BehaviourContainer = parent.behaviour_container
onready var sprite = parent.sprite
onready var hurt_box = parent.hurt_box
onready var hurt_box_collision = parent.hurt_box_collision
onready var health_bar = parent.hurt_box_collision
onready var health_bar_hide_timer = parent.health_bar_hide_timer

onready var state = parent.state
onready var STATES = parent.STATES


func is_alive():
	return parent.is_alive()


func is_disabled():
	return parent.is_disabled()


func get_node(path):
	return parent.get_node(path)

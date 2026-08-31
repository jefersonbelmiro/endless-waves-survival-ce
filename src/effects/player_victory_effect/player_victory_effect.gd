extends Node2D

var zoom_speed = 1
var target_zoom = 0.5
var current_zoom = 1

onready var camera = $camera_2d
onready var sfx = $sfx


func _ready():
	Engine.time_scale = 0.5

	# turn player not alive
	Global.player.state = Global.player.STATES.SPAWNING
	Global.player.hide()
	Global.add_dead_effect(Global.player.global_position, Global.player.color)
	
	yield(get_tree().create_timer(0.2, false), 'timeout')
	sfx.play()


func _exit_tree():
	Engine.time_scale = 1


func _physics_process(delta):
	current_zoom = lerp(current_zoom, target_zoom, zoom_speed * delta)
	camera.zoom = Vector2(current_zoom, current_zoom)


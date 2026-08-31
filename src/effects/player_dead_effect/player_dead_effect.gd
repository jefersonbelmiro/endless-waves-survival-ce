extends Node2D

signal completed()

var zoom_speed = 1
var target_zoom_factor = 0.5
var target_zoom: float
var current_zoom: float

onready var camera = $camera_2d
onready var sprite = $animated_sprite
onready var sfx = $sfx


func _ready():
	camera.zoom = Global.player.camera.zoom
	camera.offset = Global.player.camera.offset
	camera.light_mask = Global.player.camera.light_mask
	camera.global_position = Global.player.global_position

	current_zoom = camera.zoom.x
	target_zoom = current_zoom * target_zoom_factor

	sprite.frames = Global.player.sprite.frames
	sprite.animation = 'idle'
	sprite.frame = 1
	sprite.flip_h = Global.player.sprite.flip_h
	
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, 'modulate', Color(0,0,0), 0.5)
	tween.connect("finished", self, "_on_tween_finished")

	Global.remove_current_time_scale()
	Engine.time_scale = 0.3
	# _drop_backpack()
	get_tree().create_timer(0.2, false).connect('timeout', sfx, 'play')
	get_tree().create_timer(1.8, false).connect('timeout', self, '_exit_tree')


func _process(delta):
	current_zoom = lerp(current_zoom, target_zoom, zoom_speed * delta)
	camera.zoom = Vector2(current_zoom, current_zoom)


func _exit_tree():
	Engine.time_scale = 1


func _drop_backpack():
	var drops = []
	for index in Global.player.backpack.data.size():
		var item = Global.player.backpack.data[index]
		if item.size == 0:
			continue
		drops.append({ id = item.value.id, texture = item.value.icon })
	Global.drop_radius(drops, Global.player.global_position, 20, true)


func _on_tween_finished():
	sprite.hide()
	Global.add_dead_effect(global_position, Color(0, 0, 0))

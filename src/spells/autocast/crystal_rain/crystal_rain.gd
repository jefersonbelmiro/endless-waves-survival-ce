extends Node2D

export var hit_effect_color = Color('#6297c5')

var target_position = Vector2()
var velocity = Vector2()
var caster: BaseCaster
var spell_data

#var _target_marker

#onready var glow = $glow
onready var sprite = $animated_sprite
onready var sfx = $sfx

func _ready():
	spell_data = caster.get_data()

#	_target_marker = Global.add_target_marker(target_position, 20) 


func _physics_process(delta):
	global_position += velocity * delta
	
	if global_position >= target_position:
		_explosion()


func _explosion():
	call_deferred("set_physics_process", false)
	sprite.hide()

	Global.add_floor_hit_effect(global_position, caster.get_area(), hit_effect_color)
	
	sfx.pitch_scale = rand_range(0.7, 1)
	sfx.play()
	
#	_target_marker.queue_free()
#	if Settings.get_glow_effect():
#		glow.show()
	
	# wait animation to get full size
	get_tree().create_timer(0.15, false).connect("timeout", Global, 'add_hit_box_area_from_source', [self])
	
	# glow timeout
#	if Settings.get_glow_effect():
#		get_tree().create_timer(0.25, false).connect("timeout", glow, 'hide')
	

func _on_cold_bolt_body_entered(_body):
	queue_free()


func _on_sfx_finished():
	queue_free()

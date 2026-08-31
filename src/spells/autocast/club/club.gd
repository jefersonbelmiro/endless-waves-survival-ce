extends Node2D

var caster: BaseCaster
var spell_data
var direction = Vector2()
var initial_factor = 0.75
var initial_area = 32
var final_scale: Vector2
var area = 64
var position_normal: Vector2

var area_position: Vector2
var area_scale_factor: float

onready var sprite = $sprite


func _ready():
	spell_data = caster.get_data()
	area = caster.get_area()
	final_scale = FP.calculate_scale_from_area(area, initial_area, initial_factor) 
	sprite.scale = final_scale
	global_position = _get_position()

	var animation_speed = sprite.frames.get_animation_speed("attack")
	var animation_scale =  animation_speed / caster.invoker.stats.attack_speed_time / animation_speed
	sprite.speed_scale = animation_scale

	sprite.connect("animation_finished", self, "_on_sprite_attack_animation_finished", [], CONNECT_ONESHOT)
	sprite.play("attack")
	position_normal = direction


func _physics_process(_delta):
	global_position = _get_position()


func _get_position():
	return caster.invoker.global_position + direction * final_scale.x * 20


func _on_sprite_attack_animation_finished():
	var final_position = _get_position() + direction * 15
	var duration = 0.1
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_parallel()
	
	sprite.play("slash")
	tween.tween_property(sprite, 'modulate:a', 0.2, duration)
	tween.tween_property(sprite, 'global_position', final_position, duration)
	tween.connect("finished", self, "queue_free")

	area_position = final_position + direction * 10
	area_scale_factor = 0.65
	Global.add_hit_box_area_from_source(self)
	

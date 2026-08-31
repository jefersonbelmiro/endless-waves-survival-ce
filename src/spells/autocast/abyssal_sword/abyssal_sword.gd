extends Node2D

var caster: BaseCaster
var spell_data
var direction = Vector2()

var final_scale: Vector2
var area = 20
var position_normal: Vector2
var backwards = false

var area_position: Vector2
var area_scale_factor: float

onready var sprite = $sprite


func _ready():
	spell_data = caster.get_data()
	area = caster.get_area()
	sprite.scale = final_scale
	global_position = _get_position()
	
	if backwards:
		sprite.rotation_degrees = -45 + rand_range(-20, 20)
		sprite.flip_h = true
		sprite.flip_v = false
	else:
		sprite.flip_h = false
		sprite.flip_v = false
		sprite.rotation_degrees = 225 + rand_range(-20, 20) 

	var animation_speed = sprite.frames.get_animation_speed("attack")
	var animation_scale =  animation_speed / caster.invoker.stats.attack_speed_time / animation_speed
	sprite.speed_scale = animation_scale

	sprite.connect("animation_finished", self, "_on_sprite_attack_animation_finished", [], CONNECT_ONESHOT)
	sprite.play("attack")
	position_normal = direction
	_create_phade_anim()
	Global.add_hit_box_area_from_source(self)


func _physics_process(_delta):
	global_position = _get_position()


func _get_position():
	return caster.invoker.global_position + direction * final_scale.x * 10


func _create_phade_anim():
	var duration = caster.invoker.stats.attack_speed_time * 0.2
	
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_parallel()
	tween.tween_property(self, 'modulate:a', 0.0, duration)


func _on_sprite_attack_animation_finished():
	queue_free()
	

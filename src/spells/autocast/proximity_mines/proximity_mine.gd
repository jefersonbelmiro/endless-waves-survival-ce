extends Area2D

export var hit_effect_color = Color('#c56762')

var target_position: Vector2
var modifiers

var projectile_speed: float
var velocity = Vector2.DOWN
var caster: BaseCaster
var spell_data
var exploding = false

onready var collision = $collision_shape_2d
onready var explosion_timer = $explosion_timer


func _ready():
	spell_data = caster.get_data()
	if 'duration' in spell_data && spell_data.duration:
		explosion_timer.start(caster.get_duration())


func _physics_process(delta):
	var direction = target_position - global_position
	velocity = direction.normalized() * projectile_speed
	global_position += velocity * delta

	if global_position.distance_to(target_position) < 10:
		call_deferred('set_physics_process', false)


func explode():
	if exploding:
		return
	exploding = true
	Global.add_hit_box_area_from_source(self)
	if Global.node_in_viewport(self):
		Global.add_floor_hit_effect(global_position, spell_data.get_area(), hit_effect_color)
		SFX.add_explosion_short()
	queue_free()


func _on_mine_area_entered(_area_obj):
	explode()


func _on_mine_body_entered(body):
	target_position = global_position
	if body.is_in_group("walls"):
		explode()


func _on_explosion_timer_timeout():
	explode()

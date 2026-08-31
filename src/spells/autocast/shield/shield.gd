extends Node2D

signal deaded()

onready var stats = $stats
onready var hurt_box = $hurt_box
onready var hurt_box_collision = $hurt_box/collision_shape_2d
onready var hurt_box_shape: CircleShape2D = $hurt_box/collision_shape_2d.shape
onready var collision = $collision_shape_2d
onready var collision_shape: CircleShape2D = $collision_shape_2d.shape
onready var show_tween = $show_tween
onready var hide_tween = $hide_tween
onready var sprite = $sprite

var caster: BaseCaster
var spell_data
	
var shape_initial_area = 18
var shape_initial_factor = 0.15
var alive = true
var damage_blocked = 0
var host_disabled = false


func _ready():
	spell_data = caster.get_data()
	stats.max_health = spell_data.damage_block
	stats.current_health = spell_data.damage_block
	hurt_box_shape.radius = spell_data.get_area() * 0.5
	# small to hurt_box detect collisions
	collision_shape.radius = hurt_box_shape.radius * 0.8

	var scale_factor = (hurt_box_shape.radius / shape_initial_area - 1) * shape_initial_factor + shape_initial_factor
	var scale = Vector2(scale_factor, scale_factor)
	sprite.scale = scale

	var initial_scale = scale * 0.6
	sprite.scale = initial_scale
	show_tween.interpolate_property(sprite, 'scale', initial_scale, scale, 0.8, Tween.TRANS_ELASTIC,Tween.EASE_OUT)
	show_tween.start()
	

func _process(_delta):
	if caster.invoker.dashing:
		hurt_box_collision.set_deferred('disabled', true)
		collision.set_deferred('disabled', true)
	else:
		hurt_box_collision.set_deferred('disabled', false)
		collision.set_deferred('disabled', false)


func is_alive():
	return alive


func _on_stats_hitted(result: Dictionary):
	# source_node may not exist when damage happens after node is freed
	if 'source_node' in result && is_instance_valid(result.source_node): 
		if !'attack_type' in result || result.attack_type != Global.ATTACK_TYPE.RANGE:
			var owner_behaviors = result.source_node.get_node_or_null('behaviour_container')
			if owner_behaviors && owner_behaviors.has('knockback'):
				var knockback_obj = { damage_knockback = spell_data.damage_knockback, position = global_position }
				owner_behaviors.get('knockback').hitted(knockback_obj)
	if 'damage' in result:
		damage_blocked += result.damage
		Global.log_spell_damage(caster.id, result.damage)


func _on_stats_deaded():
	call_deferred('set_process', false)
	if host_disabled:
		caster.invoker.set_hurt_box_disabled(false)

	hurt_box_collision.set_deferred('disabled', true)
	collision.set_deferred('disabled', true)
	hide_tween.interpolate_property(sprite, 'scale', sprite.scale, sprite.scale * 0.7, 0.3, Tween.TRANS_ELASTIC,Tween.EASE_IN)
	hide_tween.start()
	alive = false


func _on_hide_tween_tween_all_completed():
	if 'explosion' in spell_data && spell_data.explosion:
		var explosion_area = spell_data.get_area() * 2
		var hit_data = {
			source_node = caster.invoker,
			source_id = 'shield_explosion',
			area = explosion_area,
			damage = spell_data.explosion_damage,
			damage_knockback = spell_data.damage_knockback,
			damage_type = Global.DAMAGE_TYPE.MAGIC,
		}
		var center_position = caster.invoker.collision.position
		var hit_box_area = Global.create_hit_box_area(global_position, hit_data, "enemy_hurtbox")
		hit_box_area.position = center_position
		caster.invoker.add_child(hit_box_area)

		var floor_hit_effect = Global.create_floor_hit_effect(global_position, explosion_area, Color('#0fa2ff'))
		floor_hit_effect.position = center_position
		caster.invoker.add_child(floor_hit_effect)

		SFX.add_explosion_short()

	emit_signal("deaded")
	queue_free()


func _on_show_tween_tween_all_completed():
	if stats.current_health > 0:
		host_disabled = true
		caster.invoker.set_hurt_box_disabled(true)

	hurt_box_collision.set_deferred('disabled', false)
	collision.set_deferred('disabled', false)

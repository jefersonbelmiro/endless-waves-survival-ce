extends Node2D

export var glow_color = Color()

var target: Node2D
var source: Node2D
var target_position: Vector2

var bounces = 0
var bounced_targets = []

var caster: BaseCaster
var glow_node
var updates = 4

var angle_var = 50
var source_margin = 10
var target_margin = 10

onready var inner_line = $inner_line_2d
onready var outer_line = $outer_line_2d
onready var tween = $tween
onready var sfx = $sfx


func _ready():
	randomize()
	if is_instance_valid(source) && 'collision' in source:
		source_margin = source.collision.shape.radius
	if is_instance_valid(target) && 'collision' in target:
		target_margin = target.collision.shape.radius

	if Settings.get_glow_effect():
		glow_node =  Global.glow_effect_scene.instance()
		glow_node.global_position = target.global_position
		glow_node.modulate = glow_color
		glow_node.scale = Vector2(0, 0)
		glow_node.z_index = 200
		Global.game.add_child(glow_node)
	
	sfx.pitch_scale = rand_range(0.8, 1)
	sfx.play()
	_update()

	tween.interpolate_property(inner_line, 'modulate:a', 1, 0.2, 0.2, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0.1)
	tween.interpolate_property(outer_line, 'modulate:a', 1, 0.2, 0.2, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0.1)
	if Settings.get_glow_effect():
		tween.interpolate_property(glow_node, 'scale', Vector2(0.5, 0.5), Vector2(0.9, 0.9), 0.3, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	tween.start()


func _update():
	if is_instance_valid(target):
		if glow_node:
			glow_node.global_position = target.global_position
		target_position = to_local(target.global_position)
	if is_instance_valid(source):
		global_position = source.global_position
	inner_line.points = _get_points()
	outer_line.points = inner_line.points

	updates -= 1
	if updates == 2:
		_bounce()
		_hit()
	elif updates <= 0:
		_die()


func _get_points():
	var iterations = 20
	var curr_line_len = 0
	var direction = target_position.normalized()
	var dist_lenght = (target_position - (direction * target_margin)).length()
	var start_point = direction * source_margin
	var points = [start_point]
	var min_segment_size = max(dist_lenght/30, 1)
	var max_segment_size = min(dist_lenght/15, 10)

	while iterations > 0 && curr_line_len < dist_lenght && dist_lenght > 10:
		iterations -= 1
		var move_vector = start_point.direction_to(target_position) * rand_range(min_segment_size, max_segment_size)
		var new_point = start_point + move_vector
		var new_point_rotated = start_point + move_vector.rotated(deg2rad(rand_range(-angle_var, angle_var)))
		points.append(new_point_rotated)
		start_point = new_point
		curr_line_len = start_point.length()

	points.append(target_position - (direction * target_margin))
	return points


func _bounce():
	bounces += 1
	var data = caster.data
	if bounces >= data.bounces + 1 || !is_instance_valid(target):
		bounces = data.bounces + 1
		return
	bounced_targets.append(target)
	var new_target = caster.invoker.get_closest_target(target.global_position, bounced_targets, data.bounce_distance)
	if !new_target:
		bounces = data.bounces + 1 
		return
	bounced_targets.append(new_target)
	var bounce_node = caster.cast_to_target(new_target, target)
	bounce_node.bounces = bounces
	bounce_node.bounced_targets = bounced_targets


func _hit():
	if !is_instance_valid(target) || !is_instance_valid(caster):
		return _die()
	var data = {
		source_id = caster.data.id,
		target_node = target,
		damage_type = caster.data.damage_type,
		damage = caster.data.damage,
		damage_knockback = caster.data.damage_knockback,
		position = global_position,
	}
	var hit_data = caster.invoker.stats.hit(data)
	var area_obj = target.get_node('hurt_box')
	area_obj.hitted(hit_data)
	_die()


func _die():
	if glow_node:
		glow_node.queue_free()
	queue_free()


func _on_update_timer_timeout():
	_update()

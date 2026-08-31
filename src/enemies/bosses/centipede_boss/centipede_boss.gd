extends KinematicBody2D

signal targets_changed()

enum STATES { SPAWNING, IDLE, WALK, DEAD, HITTED }

export var id = 'centipede_boss'
export var base_color = Color('#ffffff')
export var body_max_size = 10
export var damage_knockback: float = 0
var state = STATES.WALK

var experience = 5000
var level = 1
var drops = {}
var data = {}

var targets = { 
	player = { use_attack_range = false },
}
var target: Node

var body_parts = []
var body_margin = 14
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var hit_box

var part_sprite_frames = preload("res://src/enemies/bosses/centipede_boss/res/part_sprite_frames.tres")
var tail_sprite_frames = preload("res://src/enemies/bosses/centipede_boss/res/tail_sprite_frames.tres")
var part_collision_shape = preload("res://src/enemies/bosses/centipede_boss/res/part_collision_shape.tres")

onready var stats: Stats = $stats
onready var behaviour_container: BehaviourContainer = $behaviour_container
onready var sprite = $animated_sprite
onready var hurt_box = $hurt_box
onready var hurt_box_collision = $hurt_box/collision_shape_2d
onready var health_bar = $health_bar
onready var health_bar_hide_timer = $health_bar/health_bar_hide_timer


func _ready():
	if !data:
		data = Database.get("enemy_" + id)
	Global.enemy_set_data(self, data)
	
	if level > 1:
		$increase_body_timer.start()

	if Settings.get_enemy_health_bar():
		health_bar.max_value = stats.max_health
		health_bar.value = stats.current_health
	
	hit_box = get_node("hit_box_melee")
	behaviour_container.get("melee_attack").connect("disabled_changed", self, "_on_attack_disabled_changed")

	for index in body_max_size:
		_add_part(index)
	_set_z_indexes()


func _physics_process(delta):
	if is_disabled():
		return

	if velocity:
		# velocity = move_and_slide(velocity)
		var collision = move_and_collide(velocity * delta, true, true, true)
		if collision && collision.collider.is_in_group("walls"):
			velocity = move_and_slide(velocity)
		else:
			global_position += velocity * delta
		sprite.rotation = velocity.angle()                   

	for index in body_parts.size():
		var target_position = global_position if index == 0 else _get_part(index - 1).node.global_position
		_move_part(index, target_position)


func is_disabled():
	return stats.is_disabled()


func set_targets(value):
	targets = value
	emit_signal("targets_changed")


func add_target(group_id: String, options = { use_attack_range = true }):
	targets[group_id] = options
	emit_signal("targets_changed")


func remove_target(group_id: String):
	targets.erase(group_id)
	emit_signal("targets_changed")


func get_target():
	return target


func _move_part(index: int, position: Vector2):
	var part = _get_part(index)
	if !is_instance_valid(part.node):
		return
	var dist = position - part.node.global_position

	if dist.length() > body_margin:
		part.node.global_position = position + (-dist.normalized() * body_margin)
	
	part.node.rotation = dist.angle()
	part.collision.position = to_local(part.node.global_position)
	part.hurt_box.global_position = part.node.global_position
	part.hit_box.global_position = part.node.global_position


func _add_part(index: int):
	var node = AnimatedSprite.new()
	node.add_to_group("targets")
	node.add_to_group("body_parts")
	node.set_as_toplevel(true)
	node.scale = sprite.scale
	node.frames = part_sprite_frames if index + 1 < body_max_size else tail_sprite_frames
	node.global_position = global_position

	var part_collision = CollisionShape2D.new()
	part_collision.shape = part_collision_shape
	add_child(part_collision)
	
	var part_hurt_box = CollisionShape2D.new()
	part_hurt_box.shape = part_collision_shape
	hurt_box.add_child(part_hurt_box)
	
	var part_hit_box = CollisionShape2D.new()
	part_hit_box.shape = part_collision_shape
	hit_box.add_child(part_hit_box)
	
	body_parts.append({ node = node, hurt_box = part_hurt_box, hit_box = part_hit_box, collision = part_collision })
	add_child(node)
	return node
	
	
func _get_part(index: int):
	return body_parts[index]
	

func _set_z_indexes():
	z_index = body_parts.size() + 1
	for index in body_parts.size():
		_get_part(index).node.z_index = body_parts.size() - index


func is_alive():
	return !(state == STATES.DEAD || state == STATES.SPAWNING)

	
func die():
	if state == STATES.DEAD:
		return
	state = STATES.DEAD
	Global.emit_signal("enemy_died", self)
	die_effect()
	die_parts()
	queue_free()


func die_parts():
	for index in body_parts.size():
		var part = _get_part(index)
		if is_instance_valid(part): 
			part.node.queue_free()


func die_effect():
	Global.add_enemy_dead_effect(global_position, base_color)
	for index in body_parts.size():
		var part = _get_part(index)
		Global.add_enemy_dead_effect(part.node.global_position, base_color)

func _on_stats_deaded():
	die()


func _on_increase_body_timer_timeout():
	if is_disabled():
		return
	if body_parts.size() > 50:
		$increase_body_timer.stop()
		return
	var tail = _get_part(body_parts.size() - 1).node
	tail.frames = part_sprite_frames
	var node = _add_part(body_parts.size())
	var tail_direction = (_get_part(body_parts.size() - 2).node.global_position - tail.global_position).normalized()
	node.global_position = tail.global_position + (-tail_direction * body_margin)
	_set_z_indexes()


func _on_health_bar_hide_timer_timeout():
	health_bar.hide()


func _on_stats_hitted(result):
	if 'damage' in result && result.damage && Settings.get_enemy_health_bar():
		health_bar.max_value = stats.max_health
		# clamp() to prevent empty bar as the damage is float
		health_bar.value = clamp(stats.current_health, stats.max_health * 0.1, stats.max_health)
		health_bar.show()
		health_bar_hide_timer.stop()
		health_bar_hide_timer.start()

	if 'damage' in result && 'source_node' in result && is_instance_valid(result.source_node):
		if result.source_node == Global.player || result.source_node.is_in_group("player_unit"):
			Global.log_spell_damage(result.source_id, result.damage)


func _on_stats_modifier_added(modifier):
	if modifier.id == 'debuff_frozen':
		for index in body_parts.size():
			var node = _get_part(index).node
			var frozen_effect_node = Global.create_frozen_effect()
			node.call_deferred('add_child', frozen_effect_node)


func _on_stats_modifier_removed(modifier):
	if modifier.id == 'debuff_frozen':
		for index in body_parts.size():
			var node = _get_part(index).node
			var frozen_effect_node = node.get_node_or_null('frozen_effect')
			if frozen_effect_node:
				node.call_deferred('remove_child', frozen_effect_node)


func _on_attack_disabled_changed(disabled: bool):
	for collision in hit_box.get_children():
		collision.set_deferred('disabled', disabled)



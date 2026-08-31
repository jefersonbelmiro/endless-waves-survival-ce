extends KinematicBody2D
class_name TargetBase

signal targets_changed()

enum STATES { SPAWNING, IDLE, WALK, DEAD, HITTED }

export var id = 'chase'
export var base_color = Color('#ffffff')
export var sync_animation_with_move_speed = true
export var spawn_animation = true
export var spawn_animation_type = 'spawn'

var level: int = 1
var drops = {}
var data = {}
var state = STATES.SPAWNING

var targets = { 
	player = { use_attack_range = false },
}
var target: Node

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var state_animations = {
	STATES.IDLE: "idle",
	STATES.WALK: "walk",
	STATES.HITTED: "walk",
}

# move_and_slide | move_and_collide | move_increase
var move_method = "move_and_slide"
var current_move_method = move_method
var walk_animation_speed := 0

onready var sprite = $animated_sprite
onready var shadow = $shadow
onready var stats: Stats = $stats
onready var behaviour_container: BehaviourContainer = $behaviour_container
onready var health_bar = $health_bar
onready var health_bar_hide_timer = $health_bar/health_bar_hide_timer
onready var hurt_box = $hurt_box
onready var hurt_box_collision = $hurt_box/collision_shape_2d
onready var collision = $collision_shape_2d


func _ready():
	randomize()
	
	if spawn_animation:
		if spawn_animation_type == 'start':
			var spawn_effect = Global.add_start_effect(self)
			spawn_effect.connect("finished", self, "_on_spawn_effect_finished")
		else:
			var spawn_effect = Global.add_spawn_effect(self)
			spawn_effect.connect("finished", self, "_on_spawn_effect_finished")

		sprite.hide()
		shadow.hide()
		collision.disabled = true
		hurt_box_collision.disabled = true
		behaviour_container.disable_group("attack")
		behaviour_container.disable_group("move")
	else:
		state = STATES.IDLE
		collision.set_deferred('disabled', false)
		hurt_box_collision.set_deferred('disabled', false)

	if !data:
		data = Database.get("enemy_" + id)
	Global.enemy_set_data(self, data)
	
	if sync_animation_with_move_speed:
		walk_animation_speed = sprite.frames.get_animation_speed("walk")

	_sync_stats_update()
	
	sprite.play('walk')
	sprite.frame = randi() % sprite.frames.get_frame_count('walk')

	if Settings.get_enemy_health_bar():
		health_bar.max_value = stats.max_health
		health_bar.value = stats.current_health


func _process(_delta):
	if !is_alive():
		return

	# fix walk state
	if state == STATES.IDLE && velocity:
		state = STATES.WALK

	if state_animations.has(state):
		var animation = state_animations.get(state)
		if sprite.frames.has_animation(animation):
			sprite.play(animation)

	var disabled = is_disabled()
	if !disabled && direction:
		sprite.flip_h = direction.x < 0
	elif disabled:
		sprite.stop()
	
	
func _physics_process(delta):
	if !is_alive():
		return
	if velocity:
		if current_move_method == "move_increase":
			global_position += velocity * delta
		elif current_move_method == "move_and_slide":
			velocity = move_and_slide(velocity)
		else:
			move_and_collide(velocity * delta)


func is_alive():
	return !(state == STATES.DEAD || state == STATES.SPAWNING)

	
func die():
	if state == STATES.DEAD:
		return

	die_effect()

	state = STATES.DEAD
	queue_free()
	Global.emit_signal("enemy_died", self)


func die_effect():
	Global.add_enemy_dead_effect(global_position, base_color)


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


func _sync_stats_update():
	if sync_animation_with_move_speed && stats.move_speed && data.stats.move_speed:
		# var sync_animation_speed = min(2.5, float(stats.move_speed) / float(data.stats.move_speed))
		var sync_animation_speed = walk_animation_speed * float(stats.move_speed) / float(data.stats.move_speed)
		sprite.frames.set_animation_speed('walk', sync_animation_speed)
		if sync_animation_speed <= 0:
			sprite.frame = 0


func _on_stats_deaded():
	die()


func _on_stats_modifiers_applied():
	_sync_stats_update()


func _on_stats_hitted(result: Dictionary):
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
	

func _on_health_bar_hide_timer_timeout():
	health_bar.hide()


func _on_spawn_effect_finished():
	state = STATES.IDLE
	sprite.show()
	shadow.show()
	collision.set_deferred('disabled', false)
	hurt_box_collision.set_deferred('disabled', false)
	behaviour_container.enable_group("attack")
	behaviour_container.enable_group("move")



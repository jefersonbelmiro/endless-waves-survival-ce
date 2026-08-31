extends KinematicBody2D
class_name Player

signal state_changed(value)

export var id = 'player'
export var color = Color()

enum STATES { SPAWNING, IDLE, WALK, DEAD, HITTED, CHANNELING }

var level: int = 1
var experience = 0
var next_level_exp = 0
var coins = 0
var upgrade_points = 0
var spells = {}

var accerelation: int = 30
var friction: float = 0.15

var input_direction: Vector2 = Vector2.ZERO
var direction = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO

var knockback_force = 0
var knockback_direction = Vector2.ZERO
var dashing = false
var ultimate_buff_effect_count = 0
var walk_animation_speed := 0

var data = {}
var state = STATES.SPAWNING setget set_state
var backpack = Backpack.new(self)
var deck
# var input_aim_marker
var aim_mode_controller
var spawn_effect

onready var stats: Stats = $stats
onready var camera: Camera2D = $camera
onready var sprite = $animated_sprite
onready var shadow = $shadow
onready var pick_area_collision = $pick_area/collision_shape_2d
onready var pick_area_shape = $pick_area/collision_shape_2d.shape
onready var casters_container = $casters_container
onready var input_controller = $input_controller
onready var hurt_box = $hurt_box
onready var hurt_box_collision = $hurt_box/collision_shape_2d
onready var hurt_box_collision_wrapper = ObjectWrapper.new(hurt_box_collision, { deferred = true, disabled = false })
onready var collision = $collision_shape_2d
onready var collision_wrapper = ObjectWrapper.new(collision, { deferred = true, disabled = false })


func _ready():
	randomize()
	# show after spawn effect
	# @SEE _on_spawn_effect()
	hide()
	spawn_effect = Global.add_start_effect(self)
	spawn_effect.connect("finished", self, "_on_spawn_effect_finished")
	Global.char_set_data(self, data)
	set_level(1)
	backpack.load()
	walk_animation_speed = sprite.frames.get_animation_speed("walk")


func _process(_delta):
	if !is_alive():
		return
	input_direction = input_controller.get_direction()

	if aim_mode_controller && input_controller.get_aim_direction():
		direction = input_controller.get_aim_direction()
	elif input_direction:
		direction = input_direction

	var disabled = is_disabled()
	if disabled:
		sprite.stop()
	elif input_direction:
		sprite.play('walk')
	elif !dashing:
		sprite.play('idle')
		
	if !disabled && direction.x != 0:
		sprite.flip_h = direction.x < 0
		shadow.position.x = 1 if sprite.flip_h else 0
 

func _physics_process(_delta: float) -> void:
	if !is_alive():
		return
	_move()


func set_state(value):
	if state == STATES.DEAD:
		return
	var diff = value != state
	state = value
	if diff:
		emit_signal("state_changed", state)


func set_level(value: int):
	level = value
	next_level_exp = _get_level_exp()
	Global.log_player_level(level)


func die():
	if state == STATES.DEAD:
		return
	state = STATES.DEAD
	hide()
	Global.emit_signal('player_deaded')


func is_alive():
	return !(state == STATES.DEAD || state == STATES.SPAWNING)


func is_dead():
	return state == STATES.DEAD


func is_disabled():
	return stats.is_disabled()


func is_channeling():
	return state == STATES.CHANNELING


func set_hurt_box_disabled(value: bool):
	hurt_box_collision_wrapper.set_disabled(value)


func set_body_collision_disabled(value: bool):
	collision_wrapper.set_disabled(value)


func set_body_collision_layer(value):
	Global.node_set_collision_layer_deferred(self, value)


func add_experience(value):
	if !is_alive():
		return
	experience += value
	var levelup = false
	while experience >= next_level_exp:
		levelup = true
		upgrade_points += 1
		experience -= next_level_exp
		set_level(level + 1)

	if levelup:
		Global.emit_signal('player_level_changed')
		Global.emit_signal('player_upgrade_points_changed')
		call_deferred('add_child_below_node', stats, Global.create_levelup_effect())
		call_deferred('add_child', Global.create_levelup_text())
	
	Global.emit_signal('player_exp_changed')
	
	
func add_coins(value: int):
	if !is_alive():
		return
	coins += value
	Global.emit_signal('player_coins_changed', value)


func add_consumable(consumable_data):
	stats.add_modifier(consumable_data.duplicate())


# @DEPRECATED
# @SEE add_card
func add_spell(card_id: String):
	return add_card(card_id)


func add_summon(card_id: String):
	if !has_card(card_id):
		add_card(card_id)
	spells[card_id].cast()


func add_card(card_id: String):
	if spells.has(card_id):
		return upgrade_spell(card_id)
	spells[card_id] = casters_container.add_caster(card_id) 

	var card_data = get_card_data(card_id)
	if 'target_type' in card_data && card_data.target_type == Global.SPELL_TARGET_TYPE.AIM_VECTOR && !aim_mode_controller:
		aim_mode_controller = Global.aim_mode_controller.instance()
		call_deferred("add_child", aim_mode_controller)

	CardHelper.set_deck(card_data, deck)


# @DEPRECATED
# @SEE has_card
func has_spell(spell_id: String):
	return has_card(spell_id)


func has_card(card_id: String):
	return spells.has(card_id)


func get_spell(spell_id: String):
	return spells.get(spell_id)


func get_card_data(spell_id: String):
	return spells.get(spell_id).get_data()


# @DEPRECATED
# @SEE remove_card
func remove_spell(spell_id: String):
	remove_card(spell_id)


func remove_card(spell_id: String):
	spells.erase(spell_id)
	casters_container.remove_caster(spell_id)


func upgrade_spell(spell_id: String, next_level = null):
	var caster = spells[spell_id]
	caster.upgrade(next_level)
	Global.log_spell_level(spell_id, caster.get_data().level)


# @FIXME use area2d(circle) to detect targets
func get_closest_target(position_find = global_position, ignore = [], distance = stats.attack_range):
	return Targets.get_closest_target(position_find, ignore, distance)


func get_closest_target_area(area, ignore = [], position_find = global_position):
	return Targets.get_closest_target(position_find, ignore, area / 2.0)
								 

func get_random_targets(size = 1):
	return Targets.get_random_targets(global_position, [], size, stats.attack_range)
	

func get_random_target():
	return Targets.get_random_target(global_position, [], stats.attack_range)


func get_random_attack_range_position():
	var target_area = Vector2.ONE * stats.attack_range 
	var x = rand_range(-target_area.x, target_area.x)
	var y = rand_range(-target_area.y, target_area.y)
	return global_position + Vector2(x, y)


func target_in_attack_range(target):
	return Targets.in_range(target, global_position, stats.attack_range)


func target_in_area(target, area: float):
	return Targets.in_range(target, global_position, area)


func _move():
	if knockback_force:
		velocity = knockback_direction * knockback_force
		knockback_force = lerp(knockback_force, 0, 0.1)
		if knockback_force < 10:
			knockback_force = 0
	
	var is_disabled = is_disabled()
	if (!dashing && !knockback_force) || (input_direction && !is_disabled):
		velocity += input_direction * accerelation
	elif dashing && !input_direction:
		velocity += direction * accerelation
		
	if is_disabled:
		velocity = Vector2.ZERO
	elif !knockback_force:
		velocity = velocity.limit_length(stats.move_speed)

	if velocity:
		velocity = Vector2(int(velocity.x), int(velocity.y))
	
	velocity = move_and_slide(velocity)
	if !input_direction && velocity:
		velocity = lerp(velocity, Vector2.ZERO, friction)


func apply_modifiers():
	# update player modifiers
	stats.apply_modifiers()


func set_ultimate_buff_effect(value: bool):
	ultimate_buff_effect_count += 1 if value else -1
	if ultimate_buff_effect_count < 0:
		ultimate_buff_effect_count = 0
	if ultimate_buff_effect_count > 0:
		sprite.material.set_shader_param('border_color', color + Color(0.2, 0.2, 0.2, -0.2))
		sprite.material.set_shader_param('add_border', true)
	else:
		sprite.material.set_shader_param('add_border', false)
	

func _sync_stats_update():
	# update animation speed
	var sync_animation_speed = walk_animation_speed * float(stats.move_speed) / float(data.stats.move_speed)
	sprite.frames.set_animation_speed('walk', sync_animation_speed)
	if sync_animation_speed <= 0:
		sprite.frame = 0
	# sprite.speed_scale = min(2.5, float(stats.move_speed) / float(data.stats.move_speed))
	pick_area_shape.radius = stats.pick_area * 0.5
	dashing = stats.modifiers.has('dash')


func _get_level_exp():
	if level < 10:
		return ceil(level * 30)
	elif level < 20:
		return ceil(level * 35)
	elif level < 50:
		return ceil(level * 40)
	return ceil(level * 50)


func _on_stats_deaded():
	die()


func _on_stats_hitted(result: Dictionary):
	if 'damage_knockback' in result && result.damage_knockback:
		knockback_direction = (result.position - global_position).normalized() * -1
		knockback_force = result.damage_knockback
	if 'damage' in result && result.damage:
		Global.log_player_damage_taken(result.damage)


func _on_stats_health_changed():
	Global.emit_signal("player_health_changed")


func _on_stats_modifiers_applied():
	_sync_stats_update()
	

func _on_spawn_effect_finished():
	show()
	state = STATES.IDLE
	Global.emit_signal('player_spawned')


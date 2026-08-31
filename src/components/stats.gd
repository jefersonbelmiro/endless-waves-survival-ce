extends Node
class_name Stats

signal hitted(data)
signal deaded()
signal health_changed()
signal modifiers_applied()
signal modifier_added(_modifier_data)
signal modifier_removed(_modifier_data)

export var move_speed: float = 0 setget set_move_speed
export var max_health: float = 0
export var base_damage: float = 0
export var health_regen: float = 0 setget set_health_regen

# @FIXME Is this the right place for these properties?
export var pick_area: int = 0
export var spell_area: int = 0
export var spell_duration: float = 0
export var max_projectiles: int = 0
export var projectile_speed: float = 0
export var damage_knockback: float = 0

export var evasion: float = 0
export var cooldown_reduction: float = 0
export var defense_reduction: float = 0
export var magic_defense_reduction: float = 0
export var status_resistance: float = 0
export var magic_damage_factor: float = 0
export var physical_damage_factor: float = 0

export var experience_factor: float = 0.0
export var drop_proc_chance_factor: float = 0.0
export var collect_coin_factor: float = 0.0
export var critical_factor: float = 1.5
export var critical_proc_chance: float = 0.0
export var lifesteal_factor: float = 0.05
export var lifesteal_proc_chance: float = 0.0
export var healing_effectiveness: float = 0.0
export var defense: float = 0.0
export var magic_defense: float = 0.0
export var damage_block: float = 0.0
export var attack_range:float = 0.0
export var attack_speed:float = 15.0
export var attack_time: float = 1.8 
export var minimal_damage: int = 1

export var invulnerable_count: int = 0
export var undying_count: int = 0

var invulnerable = false setget set_invulnerable, get_invulnerable
var undying = false setget set_undying, get_undying

var attack_speed_time: float = 0
var current_health: float setget set_current_health

# values without modifiers
var raw_value = {}
var modifier_keys = [
	'move_speed',
	'max_health',
	'health_regen', 
	'pick_area', 
	'spell_area', 
	"base_damage",
	'defense',
	"defense_reduction",
	"magic_defense",
	"magic_defense_reduction",
	'attack_range',
	'attack_speed',
	"healing_effectiveness",
	"cooldown_reduction",
	"status_resistance",
	"evasion",
	"experience_factor",
	"drop_proc_chance_factor",
	"collect_coin_factor",
	"critical_factor",
	"critical_proc_chance",
	"lifesteal_factor",
	"lifesteal_proc_chance",
	"damage_block",
	"magic_damage_factor",
	"physical_damage_factor",
	"max_projectiles",
	"projectile_speed",
	"spell_duration",
	"damage_knockback",
	"minimal_damage",
	"invulnerable",
	"undying",
]
var modifiers = {}
var modifier_added = {}
var modifier_removed = {}
var modifier_process = {}
var modifier_apply_damage = {}
var modifier_take_damage = {}
var parent: Node

var health_regen_timer: Timer
var modifiers_mark_for_apply = false

func _ready():
	randomize()
	parent = get_parent()
	self.current_health = max_health
	for key in modifier_keys:
		raw_value[key] = self[key]

	_update_attrs()


func _process(delta):
	if modifiers_mark_for_apply:
		modifiers_mark_for_apply = false
		_apply_modifiers()
	for modifier_id in modifier_process.keys():
		modifiers[modifier_id]._process(delta)

	
func set_raw_value(key: String, value):
	self[key] = value
	raw_value[key] = self[key]
	apply_modifiers()


func set_move_speed(value: float):
	move_speed = value
	if move_speed < 0:
		move_speed = 0


func set_current_health(value: float):
	current_health = value
	if current_health > max_health:
		current_health = max_health
	if current_health < 0:
		current_health = 0
		

func set_health_regen(value: float):
	if health_regen == value:
		return
	health_regen = value
	if value <= 0:
		if health_regen_timer:
			health_regen_timer.stop()
		return
	if health_regen_timer && health_regen_timer.is_inside_tree() && health_regen_timer.is_stopped():
		health_regen_timer.start()
	if !health_regen_timer:
		health_regen_timer = Timer.new()
		health_regen_timer.name = 'health_regen_timer'
		health_regen_timer.autostart = true
		health_regen_timer.connect("timeout", self, "_health_regen_timer_timeout")
		call_deferred('add_child', health_regen_timer)


func set_invulnerable(value):
	invulnerable_count = int(max(invulnerable_count + (1 if value else -1), 0))


func get_invulnerable():
	return invulnerable_count > 0


func set_undying(value):
	undying_count = int(max(undying_count + (1 if value else -1), 0))


func get_undying():
	return undying_count > 0


func hit(data):
	data.source_node = parent
	data.critical_proc_chance = critical_proc_chance
	data.lifesteal_proc_chance = lifesteal_proc_chance
	data.lifesteal_factor = lifesteal_factor

	if 'base_damage_factor' in data:
		data.damage = base_damage * data.base_damage_factor

	if 'damage' in data:
		if data.damage_type == Global.DAMAGE_TYPE.MAGIC && magic_damage_factor != 0:
			data.damage += data.damage * magic_damage_factor
		if data.damage_type == Global.DAMAGE_TYPE.PHYSICAL && physical_damage_factor != 0:
			data.damage += data.damage * physical_damage_factor

	for modifier_id in modifier_apply_damage.keys():
		modifiers[modifier_id].apply_damage(data)

	if 'damage' in data:
		if data.critical_proc_chance > 0:
			if data.critical_proc_chance >= 1 || rand_range(0, 1) <= data.critical_proc_chance:
				data.critical = true
				data.damage *= critical_factor

		if data.lifesteal_proc_chance > 0 && current_health < max_health:
			if data.lifesteal_proc_chance >= 1 || rand_range(0, 1) <= data.lifesteal_proc_chance:
				var lifesteal_value = data.damage * data.lifesteal_factor
				self.current_health += lifesteal_value
				emit_signal("health_changed")
				Global.add_lifesteal_text(lifesteal_value, parent.global_position)

	# apply spell_duration to modifier_duration
	if spell_duration && 'modifiers' in data:
		for modifier_id in data.modifiers.keys():
			var modifier = data.modifiers[modifier_id]
			if 'modifier_duration' in modifier:
				modifier = modifier.duplicate(true)
				modifier.modifier_duration += modifier.modifier_duration * spell_duration
				data.modifiers[modifier_id] = modifier

	return data


func hitted(result: Dictionary):
	if !parent.is_alive():
		return null

	if get_invulnerable() || ('invulnerable' in result && result.invulnerable):
		return null

	for modifier_id in modifier_take_damage.keys():
		modifiers[modifier_id].take_damage(result)

	if 'damage_knockback' in result && result.damage_knockback:
		if status_resistance:
			result.damage_knockback -= float(result.damage_knockback) * status_resistance
		if (!'damage' in result || !result.damage):
			emit_signal("hitted", result)
			return null

	if evasion > 0 && result.damage_type == Global.DAMAGE_TYPE.PHYSICAL:
		if rand_range(0, 1) <= evasion:
			return false

	result.damage -= damage_block
		
	if defense_reduction > 0 && result.damage_type == Global.DAMAGE_TYPE.PHYSICAL:
		result.damage -= defense_reduction * result.damage
	elif magic_defense_reduction > 0 && result.damage_type == Global.DAMAGE_TYPE.MAGIC:
		result.damage -= magic_defense_reduction * result.damage

	# set minimum damage
	if result.damage < 1:
		result.damage = minimal_damage

	if result.damage <= 0:
		return false

	self.current_health -= result.damage
		
	emit_signal("hitted", result)
	emit_signal("health_changed")

	var is_undying = get_undying() || ('undying' in result && result.undying)

	if !is_undying && current_health <= 0:
		emit_signal("deaded")
	else:
		if 'modifiers' in result && result.modifiers.size():
			for modifier_id in result.modifiers.keys():
				add_modifier(result.modifiers[modifier_id])
	
	return true


func add_modifier(data, force = false):
	if !force && 'proc_chance' in data && data.proc_chance < 1.0:
		if rand_range(0, 1) > data.proc_chance:
			return null

	if modifiers.has(data.id):
		modifiers.get(data.id).update(data)
	else:
		if typeof(data) == TYPE_DICTIONARY:
			modifiers[data.id] = Entities.create_modifier_data(data)
		else:
			modifiers[data.id] = data

		modifiers.get(data.id).host = self
		if modifiers.get(data.id).has_method('_process'):
			modifier_process[data.id] = true
		if modifiers.get(data.id).has_method('take_damage'):
			modifier_take_damage[data.id] = true
		if modifiers.get(data.id).has_method('apply_damage'):
			modifier_apply_damage[data.id] = true
		
		modifier_added[data.id] = true
	apply_modifiers()
	return true


func remove_modifier(id: String):
	if modifiers.has(id):
		modifier_removed[id] = modifiers[id]
	modifier_added.erase(id)
	modifier_process.erase(id)
	modifier_take_damage.erase(id)
	modifier_apply_damage.erase(id)
	modifiers.erase(id)
	apply_modifiers()


func apply_modifiers():
	modifiers_mark_for_apply = true


func is_disabled():
	return modifiers.has('debuff_frozen')


func _update_attrs():
	self.defense_reduction += 1 - (100 / (100 + defense))
	self.magic_defense_reduction += 1 - (100 / (100 + magic_defense))

	# # 0.05 is equal attack_speed 320
	# self.attack_speed_time = max(0.05, 1 / (attack_speed / (20 * attack_time)))

	# 0.064 is equal attack_speed 250
	# attack_time: lower value is more fast, high value more slow fianl attack speed time
	self.attack_speed_time = max(0.064, 1 / (attack_speed / (20 * attack_time)))


func _apply_modifiers():
	# reset values
	for key in raw_value.keys():
		self[key] = raw_value[key]

	for modifier_id in modifiers.keys():
		modifiers.get(modifier_id).apply_modifiers()

	_update_attrs()

	for modifier_id in modifier_added.keys():
		modifiers.get(modifier_id).added()
	
	for modifier_id in modifier_removed.keys():
		if !modifier_added.has(modifier_id):
			modifier_removed.get(modifier_id).removed()

	modifier_removed.clear()
	modifier_added.clear()

	if current_health > max_health:
		current_health = max_health
		emit_signal("health_changed")

	emit_signal('modifiers_applied')


func _health_regen_timer_timeout():
	if current_health >= max_health:
		return
	self.current_health += health_regen
	emit_signal("health_changed")

extends Node
class_name BaseCaster

var id: String
var data
var icon_node: Node
var cooldown_node: Node

# @DEPRECATED
# @SEE invoker property
var caster
var invoker

func _ready():
	data.caster = invoker
	data.invoker = invoker

	var create_icon = false
	if data.cast_type == Global.SKILL_CAST_TYPE.ULTIMATE:
		create_icon = true
	elif data.cast_type == Global.SKILL_CAST_TYPE.AUTOCAST && Settings.get_autocast_icons():
		if 'cooldown' in data:
			create_icon = true
	# var create_icon = data.cast_type == Global.SKILL_CAST_TYPE.AUTOCAST || data.cast_type == Global.SKILL_CAST_TYPE.ULTIMATE
	if 'visible' in data && !data.visible:
		create_icon = false
	if create_icon:
		create_icon()
		reset_cooldown()


func can_cast():
	return invoker.is_alive() && !invoker.is_disabled() && !invoker.is_channeling()


func create_icon():
	icon_node = Global.hud_spell_slots.add_spell(data) 
	cooldown_node = icon_node.get_node('cooldown')
	if !'cooldown' in data:
		cooldown_node.hide()
		return
	var cooldown = get_cooldown()
	cooldown_node.max_value = cooldown
	cooldown_node.value = cooldown


func update_cooldown(value):
	if !cooldown_node:
		return
	if !'cooldown' in data:
		return
	cooldown_node.value = value
	cooldown_node.max_value = get_cooldown()


func reset_cooldown():
	if !cooldown_node:
		return
	if !'cooldown' in data:
		return
	var cooldown = get_cooldown()
	cooldown_node.max_value = cooldown
	cooldown_node.value = cooldown


func get_data():
	return data


func has_upgrade():
	return CardHelper.has_upgrade(data)


func upgrade(next_level = null):
	if !next_level:
		next_level = data.level + 1
	data.upgrade(next_level)
	if cooldown_node:
		reset_cooldown()
		icon_node.label_value = data.level


func get_cooldown():
	if caster.stats.modifiers.has('absolute_chaos'):
		return 0
	elif 'cooldown' in data:
		return data.cooldown - (data.cooldown * caster.stats.cooldown_reduction) 
	return 0


func get_attack_speed_time():
	return caster.stats.attack_speed_time 


func get_max_projectiles():
	return data.get_max_projectiles()


func get_projectile_speed():
	return data.get_projectile_speed()


func get_duration():
	return data.get_duration()


func get_area():
	return data.get_area()


func add_modifiers_to_node(data_source, node: Node):
	if !'modifiers' in data_source || !data_source.modifiers:
		return
	node.modifiers = Global.sanitize_modifiers(data_source.modifiers) 



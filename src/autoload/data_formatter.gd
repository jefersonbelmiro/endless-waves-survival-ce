extends Node

var handlers = {
	percent = funcref(Formatter, 'format_percent'),
	damage_type = funcref(Formatter, 'format_damage_type'),
	short_seconds = funcref(Formatter, 'format_short_seconds'),
	per_seconds = funcref(Formatter, 'format_per_seconds'),
}

var keys = [
	'cooldown_reduction',
	'proc_chance',
	'drop_proc_chance_factor',
	'scale_factor', 
	'experience_factor',
	'critical_proc_chance',
	'lifesteal_proc_chance',
	'evasion',
	'cooldown',
	'cast_time',
	"damage",
	"damage_type",
	'damage_knockback',
	'damage_block',
	'magic_damage_factor',
	'physical_damage_factor',
	'max_projectiles',
	'spread',
	"duration",
	"area",
	'bounces',         
	'bounce_distance',
	'move_speed',
	'attack_speed',
	'base_damage',
	'attack_range',
	'defense',
	'defense_reduction',
	'magic_defense',
	'magic_defense_reduction',
	'status_resistance',
	'current_health',
	'max_health',
	'health_regen',
	'spell_area',
	'pick_area',
	'modifiers',         
	'modifier_duration',
	'healing_effectiveness',
	'projectile_speed',
	'spell_duration',
]

var key_handlers = {
	'cooldown_reduction': 'percent',
	'magic_defense_reduction': 'percent',
	'status_resistance': 'percent',
	'defense_reduction': 'percent',
	'proc_chance': 'percent',
	'critical_proc_chance': 'percent',
	'lifesteal_proc_chance': 'percent',
	'base_damage_factor': 'percent',
	'damage_factor': 'percent',
	'magic_damage_factor': 'percent',
	'physical_damage_factor': 'percent',
	'drop_proc_chance_factor': 'percent',
	'scale_factor': 'percent', 
	'healing_effectiveness': 'percent', 
	'experience_factor': 'percent', 
	'spell_duration': 'percent', 
	'damage_type': 'damage_type',
	'evasion': 'percent',
	'cooldown': 'short_seconds',
	'cast_time': 'short_seconds',
	'duration': 'short_seconds',
	'modifier_duration': 'short_seconds',
	'health_regen': 'per_seconds',
}


# interpolate data
func it_data(source, options = null):
	var add_sign = FP.safe_get(options, 'add_sign', true)
	var result = source.duplicate()
	for key in source.keys():
		if !key in keys:
			continue
		var value = format(key, source)
		if add_sign && !value.begins_with('+') && !value.begins_with('-'):
			if !options || !'ignore_sign' in options || !options.ignore_sign.has(key):
				value = "+%s" % [value] 
		var color = 'red' if value.begins_with('-') else 'green'
		result[key] = "[color=%s]%s[/color]" % [color, value]
	return result


func format_sign(value):
	if !value.begins_with('+') && !value.begins_with('-'):
		value = "+%s" % [value] 
	return value


func format_color(value):
	var color = 'red' if value.begins_with('-') else 'green'
	return "[color=%s]%s[/color]" % [color, value]


func format_key(key: String):
	if key == "experience_factor":
		return tr("EXPERIENCE")
	elif key == "critical_proc_chance":
		return tr("CRITICAL_HIT_CHANCE")
	elif key == "damage_type":
		return tr("DAMAGE")
	return tr(key.to_upper())


func format_handler(value, handler):
	if !handlers.has(handler):
		return str(value)
	var ref = handlers[handler]
	return ref.call_func(value)


func format_placeholder(value, placeholder: String, options = null):
	var color = FP.safe_get(options, 'color')
	if !color:
		return tr(placeholder).format({ value = value })
	return tr(placeholder).format({ value = "[color=%s]%s[/color]" % [color, value] })


func format_value(key, source, options = { add_color = false, add_sign = false }):
	var value = format(key, source)
	if options && 'add_sign' in options && options.add_sign:
		value = format_sign(value)
	if options && 'add_color' in options && options.add_color:
		value = format_color(value)
	return value


func format(key, source):
	if !key_handlers.has(key):
		return str(source[key])
	var name = key_handlers[key]
	if !handlers.has(name):
		push_error("invalid formatter: " + name)
		return null
	var ref = handlers[name]
	return ref.call_func(source[key])


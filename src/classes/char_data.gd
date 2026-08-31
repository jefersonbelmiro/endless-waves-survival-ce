extends Reference
class_name CharData

var data: Dictionary

func _init(data_apply: Dictionary):
	data = data_apply.duplicate(true)


func _get(property):
	if !property in data:
		return null
	return data[property]


func _set(property: String, value):
	# throw error when property not exists:
	# error: Invalid set index 'property' (on base: 'Reference (modifier_data.gd)') with value of type 'int'.
	# if !property in data:
	# 	return false
	data[property] = value
	return true


func format_stats():
	var text = ""
	for key in data.stats.keys():
		if !DataFormatter.keys.has(key):
			continue
		if key == 'magic_damage_factor':
			var value = DataFormatter.format_value(key, data.stats, { add_color = true })
			text += "%s: [color=green]%s[/color]\n" % [tr("MAGIC_DAMAGE_FACTOR"), value]
		elif key == 'physical_damage_factor':
			var value = DataFormatter.format_value(key, data.stats, { add_color = true })
			text += "%s: [color=green]%s[/color]\n" % [tr("PHYSICAL_DAMAGE_FACTOR"), value]
		elif key == 'experience_factor':
			var value = DataFormatter.format_value(key, data.stats, { add_color = true })
			text += "%s: [color=green]%s[/color]\n" % [tr("EXPERIENCE"), value]
		elif key == 'critical_proc_chance':
			var  critical_proc_chance = DataFormatter.format_value(key, data.stats, { add_color = true })
			var  critical_factor = DataFormatter.format_value('critical_factor', data.stats)
			text += "%s: [color=green]x%s (%s %s)[/color]\n" % [tr("CRITICAL"), critical_factor, critical_proc_chance, tr('CHANCE')]
		elif key == 'lifesteal_proc_chance':
			var  lifesteal_proc_chance = DataFormatter.format_value(key, data.stats, { add_color = true })
			var  lifesteal_factor = DataFormatter.format_value('lifesteal_factor', data.stats)
			text += "%s: [color=green]x%s (%s %s)[/color]\n" % [tr("LIFESTEAL"), lifesteal_factor, lifesteal_proc_chance, tr('CHANCE')]
		elif data.stats[key]:
			text += "%s: [color=green]%s[/color]\n" % [tr(key.to_upper()), DataFormatter.format_value(key, data.stats, { add_color = true })]
	return text


func duplicate(_deep = false):
	return get_script().new(data)

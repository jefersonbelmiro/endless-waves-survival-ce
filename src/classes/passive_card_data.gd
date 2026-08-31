extends ModifierData
class_name PassiveCardData

var caster
var next_upgrades = []


func _init(data_apply: Dictionary).(data_apply):
	data = CardHelper.sanitize_data(data_apply)


func set_next_upgrades(keys: Array):
	next_upgrades = keys


func upgrade(next_level = null):
	return CardHelper.upgrade(self, next_level)


func has_upgrade():
	return CardHelper.has_upgrade(data)


func get_avaliable_upgrades():
	return CardHelper.get_avaliable_upgrades(self)


func format_description():
	return CardHelper.format_description(self)


func format_cast_type():
	return CardHelper.format_cast_type(self)


func format_target_type():
	return CardHelper.format_target_type(self)


func format_level():
	return CardHelper.format_level(self)


func format_upgrades_size():
	return CardHelper.format_upgrades_size(self)


func format_details():
	return CardHelper.format_details(self)


func format_info():
	return CardHelper.format_info(self)


func format_info_with_upgrade():
	return CardHelper.format_info_with_upgrade(self)


func get_area():
	if is_instance_valid(caster):
		return data.area + caster.stats.spell_area
	return data.area


func get_max_projectiles():
	return data.max_projectiles + caster.stats.max_projectiles


func get_projectile_speed():
	return data.projectile_speed + caster.stats.projectile_speed


func get_duration():
	var duration = data.duration
	if caster.stats.spell_duration:
		duration += data.duration * caster.stats.spell_duration
	return duration


func duplicate(_deep = false):
	return get_script().new(data)



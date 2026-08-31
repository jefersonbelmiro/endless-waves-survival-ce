class_name CardHelper


static func set_deck(card_data, deck):
	if !'upgrades_data' in card_data:
		return
	if !deck || !deck.cards.has(card_data.id):
		var default_data = Entities.create_spell_data(card_data.id).upgrades_data
		card_data.upgrades_data = default_data 
	else:
		var deck_uprades_data = deck.cards.get(card_data.id).duplicate(true)
		for upgrade_id in deck_uprades_data.keys():
			var upgrade_data = deck_uprades_data[upgrade_id]
			var current_upgrade_data = card_data.upgrades_data[upgrade_id]
			for key in upgrade_data.keys(): 
				current_upgrade_data[key] = upgrade_data[key]


static func create_deck_upgrades_data(card_data):
	if 'upgrades_data'in card_data:
		var result = {}
		for upgrade_id in card_data.upgrades_data.keys():
			var upgrade_data = card_data.upgrades_data[upgrade_id]
			result[upgrade_id] = create_deck_upgrade_data(upgrade_data)
		return result
	return null


static func create_deck_upgrade_data(upgrade_data):
	return {
		active = upgrade_data.active,
		unlock_index = int(upgrade_data.unlock_index),
		max_index = int(upgrade_data.max_index),
	}


static func has_upgrade(card_data):
	if !'upgrades_data' in card_data:
		return card_data.level - 1 < card_data.upgrades.size()

	for key in card_data.upgrades_data.keys():
		var upgrade = card_data.upgrades_data[key]
		if upgrade.active && upgrade.index <= upgrade.max_index:
			return true
	return false


static func format_info_with_upgrade(card_data):
	var text = ""
	var upgrade_data = {}
	var data = card_data.data
	var upgrade_details = PoolStringArray()
	var keys_dict = data.duplicate()
	var value_format_keys = FP.safe_get(data, "value_format_keys", {})
	var card_edit_private_keys = FP.safe_get(data, "card_edit_private_keys", null)

	if 'upgrades_data' in data:
		for upgrade_key in card_data.upgrades_data.keys():
			var upgrade = data.upgrades_data[upgrade_key]
			if upgrade.index == 0 && !card_data.next_upgrades.has(upgrade_key):
				continue

			if !keys_dict.has(upgrade_key):
				keys_dict[upgrade_key] = true

			if card_data.next_upgrades.has(upgrade_key):
				if upgrade.index >= upgrade.value.size():
					push_error("format_info_with_upgrade: Try to upgrade card %s with upgrade key %s with invalid index %s" % [card_data.id, upgrade_key, upgrade.index])
					continue
				var value = upgrade.value[upgrade.index]
				upgrade_data = FP.patch_dictionary(upgrade_data, value)

			if 'new_upgrade_description' in upgrade && upgrade.index == 0:
				var description = _tr(upgrade.new_upgrade_description).format(DataFormatter.it_data(upgrade_data))
				upgrade_details.append("[color=green]%s[/color]" % [description])
			elif 'upgrade_description' in upgrade && upgrade.index > 0:
				var description = _tr(upgrade.upgrade_description).format(DataFormatter.it_data(upgrade_data))
				upgrade_details.append("[color=#775e14]%s[/color]" % [description])

	else:
		var level_index = data.level - 1
		upgrade_data = data.upgrades[level_index] if level_index >= 0 else {} 

	for key in keys_dict.keys():
		# key visible only in card edit
		if card_edit_private_keys != null && card_edit_private_keys.has(key):
			continue

		# only show upgrades values
		# if Global.is_mobile() && data.level > 0:
		# 	if !"damage_type" in upgrade_data && key == "base_damage_factor":
		# 		key = "damage_type"
		# 	elif !upgrade_data.has(key):
		# 		continue

		if value_format_keys.has(key):
			var formatter = value_format_keys[key].format if 'format' in value_format_keys[key] else null
			var key_tr = value_format_keys[key].tr if 'tr' in value_format_keys[key] else key.to_upper()
			var value = _get_value_with_upgrade(key, data, upgrade_data, formatter) 
			if 'format_placeholder' in value_format_keys[key]:
				value = DataFormatter.format_placeholder(value, value_format_keys[key].format_placeholder, { color = "green" })
				text += "%s: %s\n" % [_tr(key_tr), value]
			else:
				text += "%s: [color=green]%s[/color]\n" % [_tr(key_tr), value]
			continue

		if !DataFormatter.keys.has(key):
			continue
		if key == 'damage' && 'damage_type' in keys_dict:
			continue

		if key == 'experience_factor':
			var value = _get_value_with_upgrade(key, data, upgrade_data) 
			text += "%s: [color=green]%s[/color]\n" % [_tr('EXPERIENCE'), value]
		elif key == 'critical_proc_chance':
			var value = _get_value_with_upgrade(key, data, upgrade_data) 
			text += "%s: [color=green]%s[/color]\n" % [_tr('CRITICAL_HIT_CHANCE'), value]
		elif key == 'damage_type':
			if 'base_damage_factor' in data && (data.base_damage_factor || 'base_damage_factor' in upgrade_data && upgrade_data.base_damage_factor):
				var value = _get_value_with_upgrade('base_damage_factor', data, upgrade_data)
				var value_formatted = _tr("BASE_DAMAGE_FACTOR_PLACEHOLDER").format({ value = "[color=green]%s[/color]" % [value] })
				text += "%s: %s\n" % [_tr('DAMAGE'), value_formatted]
				# text += "%s: [color=green]%s[/color] %s\n" % [_tr("DAMAGE"), value, _tr('BASE_DAMAGE')]
			elif 'damage' in data && (data.damage || 'damage' in upgrade_data && upgrade_data.damage):
				var value = _get_value_with_upgrade('damage', data, upgrade_data)
				text += "%s: [color=green]%s[/color]\n" % [_tr("DAMAGE"), value]
		elif key == 'modifiers' && data.modifiers:
			for modifier_id in data.modifiers.keys():
				var modifier = data.modifiers[modifier_id]
				if 'description' in modifier:
					text += "%s\n" % [_tr(modifier.description).format(DataFormatter.it_data(modifier, { add_sign = false }))]
		elif data[key] || (key in upgrade_data && upgrade_data[key]):
			var value = _get_value_with_upgrade(key, data, upgrade_data)
			text += "%s: [color=green]%s[/color]\n" % [_tr(key.to_upper()), value]

	if upgrade_details.size():
		text += "\n%s" % [upgrade_details.join("\n")]

	return text


static func format_info(card_data):
	var text = ""
	var data = card_data.data
	var upgrade_details = PoolStringArray()
	var keys_dict = data.duplicate()
	var value_format_keys = FP.safe_get(data, "value_format_keys", {})
	var card_edit_private_keys = FP.safe_get(data, "card_edit_private_keys", null)

	if 'upgrades_data' in data:
		for upgrade_key in card_data.upgrades_data.keys():
			var upgrade = data.upgrades_data[upgrade_key]
			if upgrade.index == 0:
				continue

			if !keys_dict.has(upgrade_key):
				keys_dict[upgrade_key] = true

			if 'upgrade_description' in upgrade:
				var value = upgrade.value[upgrade.index - 1]
				var description = _tr(upgrade.upgrade_description).format(DataFormatter.it_data(value))
				upgrade_details.append("[color=#775e14]%s[/color]" % [description])

	for key in keys_dict.keys():
		# key visible only in card edit
		if card_edit_private_keys != null && card_edit_private_keys.has(key):
			continue

		if value_format_keys.has(key):
			var key_tr = value_format_keys[key].tr if 'tr' in value_format_keys[key] else key.to_upper()
			var value
			if 'format' in value_format_keys[key]:
				value = DataFormatter.format_handler(data[key], value_format_keys[key].format)
			else:
				value = DataFormatter.format(key, data) 
			if 'format_placeholder' in value_format_keys[key]:
				value = DataFormatter.format_placeholder(value, value_format_keys[key].format_placeholder, { color = "green" })
				text += "%s: %s\n" % [_tr(key_tr), value]
			else:
				text += "%s: [color=green]%s[/color]\n" % [_tr(key_tr), value]
			continue
		
		if !DataFormatter.keys.has(key):
			continue
		if key == 'damage' && 'damage_type' in keys_dict:
			continue
		if key == 'experience_factor':
			var value = DataFormatter.format(key, data)
			text += "%s: [color=green]%s[/color]\n" % [_tr("EXPERIENCE"), value]
		elif key == 'critical_proc_chance':
			var value = DataFormatter.format(key, data)
			text += "%s: [color=green]%s[/color]\n" % [_tr("CRITICAL_HIT_CHANCE"), value]
		elif key == 'damage_type':
			if 'base_damage_factor' in data && data.base_damage_factor:
				var value = DataFormatter.format('base_damage_factor', data)
				var value_formatted = _tr("BASE_DAMAGE_FACTOR_PLACEHOLDER").format({ value = "[color=green]%s[/color]" % [value] })
				text += "%s: %s\n" % [_tr('DAMAGE'), value_formatted]
				# text += "%s: [color=green]%s[/color] %s\n" % [_tr('DAMAGE'), value, _tr('BASE_DAMAGE')]
			elif 'damage' in data && data.damage:
				var value = DataFormatter.format('damage', data)
				text += "%s: [color=green]%s[/color]\n" % [_tr('DAMAGE'), value]
		elif key == 'modifiers' && data.modifiers:
			for modifier_id in data.modifiers.keys():
				var modifier = data.modifiers[modifier_id]
				if 'description' in modifier:
					text += "%s\n" % [_tr(modifier.description).format(DataFormatter.it_data(modifier, { add_sign = false }))]
		elif data[key]:
			text += "%s: [color=green]%s[/color]\n" % [_tr(key.to_upper()), DataFormatter.format(key, data)]

	if upgrade_details.size():
		text += "\n%s" % [upgrade_details.join("\n")]

	return text


static func format_card_type(card_data):
	if !'type' in card_data.data:
		return null
	match card_data.type:
		Global.CARD_TYPE.SKILL:
			return _tr('SKILL')
		Global.CARD_TYPE.WEAPON:
			return _tr('WEAPON')


static func format_cast_type(card_data):
	match card_data.cast_type:
		Global.SKILL_CAST_TYPE.AUTOCAST:
			return _tr('AUTOCAST')
		Global.SKILL_CAST_TYPE.PASSIVE:
			return _tr('PASSIVE')
		Global.SKILL_CAST_TYPE.ULTIMATE:
			return _tr('ACTIVATE')
		Global.SKILL_CAST_TYPE.SUMMON:
			return _tr('SUMMON')


static func format_target_type(card_data):
	var data = card_data.data
	if !'target_type' in data:
		return null
	match data.target_type:
		Global.SPELL_TARGET_TYPE.TARGET_UNIT, Global.SPELL_TARGET_TYPE.RANDOM_TARGET, Global.SPELL_TARGET_TYPE.CLOSEST_TARGET:
			return _tr("TARGET_UNIT")
		Global.SPELL_TARGET_TYPE.AIM_VECTOR:
			return _tr("AIM")
	return null


static func format_details(card_data):
	var details_texts = PoolStringArray()
	var data = card_data
	if 'type' in data:
		details_texts.append(format_card_type(card_data))
	if 'cast_type' in data:
		details_texts.append(format_cast_type(card_data))
	if 'damage_type' in data:
		details_texts.append(DataFormatter.format('damage_type', data))
	var target_type = format_target_type(card_data)
	if target_type:
		details_texts.append(format_target_type(card_data))
	if 'area' in data && data.area > 0:
		details_texts.append(_tr("AREA"))
	if 'max_projectiles' in data && data.max_projectiles > 0:
		details_texts.append(_tr("PROJECTILE"))
	return "%s" % [details_texts.join(' / ')]


static func sanitize_data(data_apply):
	var result = data_apply.duplicate(true) 
	result.level = 0
	if 'type' in result && typeof(result.type) == TYPE_STRING:
		result.type = FP.enum_value_from_string(Global.CARD_TYPE, result.type)

	if 'cast_type' in result && typeof(result.cast_type) == TYPE_STRING:
		result.cast_type = FP.enum_value_from_string(Global.SKILL_CAST_TYPE, result.cast_type)
	if 'damage_type' in result && typeof(result.damage_type) == TYPE_STRING:
		result.damage_type = FP.enum_value_from_string(Global.DAMAGE_TYPE, result.damage_type)
	if 'target_type' in result && typeof(result.target_type) == TYPE_STRING:
		result.target_type = FP.enum_value_from_string(Global.SPELL_TARGET_TYPE, result.target_type)
	if 'upgrades_data' in result:
		for key in result.upgrades_data.keys():
			var upgrade = result.upgrades_data[key]
			upgrade.id = key
			upgrade.index = 0
			if !'label' in upgrade:
				upgrade.label = key.to_upper()
	return result


static func format_upgrades_size(card_data):
	var data = card_data.data
	if 'upgrades_data' in data:
		var current = 0
		var total = 0
		for key in data.upgrades_data.keys():
			total += data.upgrades_data[key].value.size()
			if data.upgrades_data[key].active:
				current += data.upgrades_data[key].max_index + 1
		return "%s: %s/%s" % [_tr('UPGRADES'), current, total]

	if data.upgrades.size():
		return "%s: %s" % [_tr('UPGRADES'), data.upgrades.size()]
	return ""


static func format_level(card_data):
	var data = card_data.data
	if 'upgrades_data' in data:
		var result = 1
		for key in data.upgrades_data.keys():
			if data.upgrades_data[key].active:
				result += data.upgrades_data[key].max_index + 1
		return "%s %s/%s" % [_tr('LEVEL'), data.level, result]

	return "%s %s/%s" % [_tr('LEVEL'), data.level, data.upgrades.size() + 1]


static func format_description(card_data):
	var data = card_data.data
	if !'description' in data || !data.description:
		return ''
	return _tr(data.description).format(DataFormatter.it_data(data))


static func get_avaliable_upgrades(card_data):
	var data = card_data.data
	var keys = []
	if 'upgrades_data' in data:
		for key in data.upgrades_data.keys():
			var upgrade = data.upgrades_data[key]
			if upgrade.active && upgrade.index <= upgrade.max_index:
				keys.append(key)
	return keys


static func upgrade(card_data, next_level = null):
	var data = card_data
	if next_level && !'upgrades_data' in data:
		var next_index = next_level - 2
		if next_index >= data.upgrades.size():
			return

		for index in range(0, next_index + 1):
			var upgrade = data.upgrades[index]
			for key in upgrade.keys():
				card_data[key] = upgrade[key]
		data.level = next_level

	for upgrade_key in card_data.next_upgrades:
		var upgrade_data = data.upgrades_data[upgrade_key]
		if upgrade_data.index >= upgrade_data.value.size():
			push_error("autocast_card_data: upgrade %s out of bounds" % [data.id])
			continue
		var upgrade = upgrade_data.value[upgrade_data.index]
		for key in upgrade.keys():
			card_data[key] = upgrade[key]
		upgrade_data.index += 1
		data.level += 1


static func get_deck_cost(deck):
	var cost = 0
	for card_id in deck.cards.keys():
		var deck_upgrades_data = deck.cards[card_id]
		var card_data = Entities.create_spell_data(card_id)
		if !'upgrades_data' in card_data:
			continue
		var card_upgrades_data = card_data.upgrades_data
		for upgrade_id in deck_upgrades_data.keys():
			var deck_upgrade = deck_upgrades_data[upgrade_id]
			var card_upgrade = card_upgrades_data[upgrade_id]
			if deck_upgrade.unlock_index <= card_upgrade.unlock_index:
				continue
			for value_index in range(card_upgrade.unlock_index + 1, deck_upgrade.unlock_index + 1):
				var value = card_upgrades_data[upgrade_id].value[value_index]
				if 'cost' in value:
					cost += value.cost
				else:
					cost += Global.DECK_CARD_UPGRADE_COST
	return cost


static func _tr(text):
	return Global.tr(text)


static func _get_value_with_upgrade(key, source_data, upgrade_data, format_handler = null):
	var value
	if format_handler:
		value = DataFormatter.format_handler(source_data[key], format_handler)
	else:
		value = DataFormatter.format(key, source_data) 
	if upgrade_data.has(key):
		var upgrade_value
		if format_handler:
			upgrade_value = DataFormatter.format_handler(upgrade_data[key], format_handler)
		else:
			upgrade_value = DataFormatter.format(key, upgrade_data)
		return "[color=grey]%s %s[/color] %s" % [value, '->', upgrade_value]
	return value



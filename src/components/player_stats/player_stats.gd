extends Control

var _default_config = {
	font_size = 8,
}

var _mobile_config = {
	font_size = 12,
}

var _config = _default_config

onready var content_container = $"%content_container"

func update():
	if Global.is_mobile():
		_config = _mobile_config

	Global.node_remove_children(content_container)

	var stats = Global.player.stats
	_create_right_row('MAX_HEALTH', "%d" % [stats.max_health])
	_create_right_row("HEALTH_REGEN", "%.2f/s" % [stats.health_regen] if stats.health_regen else "0")
	_create_right_row("HEALING_EFFECTIVENESS", "%.2f%%" % [stats.healing_effectiveness * 100] if stats.healing_effectiveness else "0")
	_create_right_row("ATTACK_RANGE", "%d" % [stats.attack_range])
	_create_right_row("PICK_AREA", "%d" % [stats.pick_area])
	_create_right_row("MOVE_SPEED", "%.2f" % [stats.move_speed])
	_create_right_row("ATTACK_SPEED", "%d" % [stats.attack_speed])
	_create_right_row("ATTACK_SPEED_RATE", "%.2f/s" % [1000/stats.attack_speed_time/1000] if stats.attack_speed_time else '0')

	var base_damage = DataFormatter.format("base_damage", stats)
	_create_right_row("BASE_DAMAGE", base_damage)

	if stats.critical_proc_chance > 0:
		var critical_proc_chance = DataFormatter.format('critical_proc_chance', stats)
		var critical_factor = DataFormatter.format('critical_factor', stats)
		var critical_value = "x%s (%s %s)" % [critical_factor, critical_proc_chance, tr('CHANCE')]
		_create_right_row("CRITICAL", critical_value)

	if stats.lifesteal_proc_chance > 0:
		var lifesteal_proc_chance = DataFormatter.format('lifesteal_proc_chance', stats)
		var lifesteal_factor = DataFormatter.format('lifesteal_factor', stats)
		var lifesteal_value = "x%s (%s %s)" % [lifesteal_factor, lifesteal_proc_chance, tr('CHANCE')]
		_create_right_row("LIFESTEAL", lifesteal_value)

	if stats.magic_damage_factor:
		var magic_damage_factor = DataFormatter.format("magic_damage_factor", stats)
		_create_right_row("MAGIC_DAMAGE_FACTOR", magic_damage_factor)

	if stats.physical_damage_factor:
		var physical_damage_factor = DataFormatter.format("physical_damage_factor", stats)
		_create_right_row("PHYSICAL_DAMAGE_FACTOR", physical_damage_factor)

	if stats.experience_factor:
		var experience_factor = DataFormatter.format("experience_factor", stats)
		_create_right_row("EXPERIENCE_FACTOR", experience_factor)

	if stats.drop_proc_chance_factor > 0:
		var drop_proc_chance_factor = DataFormatter.format("drop_proc_chance_factor", stats)
		_create_right_row("DROP_PROC_CHANCE_FACTOR", drop_proc_chance_factor)

	if stats.evasion:
		var evasion = DataFormatter.format("evasion", stats)
		_create_right_row("EVASION", evasion)

	if stats.cooldown_reduction:
		_create_right_row("COOLDOWN_REDUCTION", "%.2f%%" % [stats.cooldown_reduction * 100] if stats.cooldown_reduction else "0")

	if stats.defense:
		_create_right_row("DEFENSE", "%.2f" % [stats.defense] if stats.defense else '0')

	if stats.defense_reduction:
		_create_right_row("DEFENSE_REDUCTION", "%.2f%%" % [stats.defense_reduction * 100] if stats.defense_reduction else "0")

	if stats.magic_defense:
		_create_right_row("MAGIC_DEFENSE", "%.2f" % [stats.magic_defense] if stats.magic_defense else '0')

	if stats.magic_defense_reduction:
		_create_right_row("MAGIC_DEFENSE_REDUCTION", "%.2f%%" % [stats.magic_defense_reduction * 100] if stats.magic_defense_reduction else "0")

	if stats.status_resistance:
		_create_right_row("STATUS_RESISTANCE", DataFormatter.format("status_resistance", stats), false)
	

func _create_right_row(label: String, value, add_separator = true):
	var container = HBoxContainer.new()
	var label_node = Label.new()
	var value_node = Label.new()

	label_node.size_flags_horizontal = SIZE_EXPAND_FILL
	label_node.text = label
	label_node.set('custom_colors/font_color', Color('#acaaaa'))
	label_node.set('custom_fonts/font', Global.get_font(_config.font_size))

	value_node.text = str(value)
	value_node.set('custom_colors/font_color', Color('#acaaaa'))
	value_node.set('custom_fonts/font', Global.get_font(_config.font_size))

	container.add_child(label_node)
	container.add_child(value_node)
	content_container.add_child(container)
	if add_separator:
		var separator = HSeparator.new()
		separator.modulate = Color('#6a2b2630')
		content_container.add_child(separator)


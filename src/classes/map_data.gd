extends Reference
class_name MapData

var data: Dictionary

const placeholders = {
	kill_enemies_boss = "OBJECTIVE_KILL_BOSS",
	kill_enemies_id = "OBJECTIVE_KILL_ID", 
	kill_enemies = "OBJECTIVE_KILL_ENEMIES",
	survive_time = "OBJECTIVE_SURVIVE",
	find_exit = "OBJECTIVE_FIND_EXIT",
}

func _init(data_apply: Dictionary):
	data = data_apply.duplicate(true)
	if !'level' in data:
		data.level = 1
	if !'levels' in data:
		data.levels = 1
	if !'mode' in data:
		data.mode = Global.MAP_MODES.ENDLESS


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


func load_persisted():
	var meta = Persistent.get_map(data.id)
	data = FP.patch_dictionary(data, meta)


func get_objectives(level = data.level):
	var result = []
	if !'objectives' in data:
		return result
	for index in data.objectives.size():
		var objective = data.objectives[index]
		if !'level' in objective:
			result.append(objective)
		elif objective.level == level:
			result.append(objective)
	return result


func format_objectives():
	var objective_text = PoolStringArray()
	var objectives = get_objectives()
	for index in objectives.size():
		var objective = objectives[index]
		objective_text.append(" - " + format_objective(objective))
	return "%s: \n%s" % [tr('OBJECTIVES'), objective_text.join('\n')]


func format_objective_values(objective):
	var placeholder = ''
	var interpolate_data = objective.duplicate()
	if objective.type == 'kill_enemies':
		if 'id' in objective && objective.value == 1:
			placeholder = placeholders.kill_enemies_boss
		elif 'id' in objective:
			placeholder = placeholders.kill_enemies_id
			interpolate_data.value = "%s/%s" % [objective.current, objective.value] 
		else:
			placeholder = placeholders.kill_enemies
			interpolate_data.value = "%s/%s" % [objective.current, objective.value] 
	elif objective.type == 'survive_time':
		placeholder = placeholders.survive_time
		# if !'label'in objective:
		interpolate_data.value = Formatter.format_ellapsed(Formatter.format_timer_seconds(objective.value))
	elif objective.type == 'find_exit':
		placeholder = placeholders.find_exit
	else:
		push_error("Invalid objective type: " + objective.type)
		return null
	if 'label' in objective:
		placeholder = objective.label
	return tr(placeholder).format(interpolate_data)


func format_objective(objective):
	var placeholder = ''
	var interpolate_data = objective.duplicate()
	if objective.type == 'kill_enemies':
		if 'id' in objective && objective.value == 1:
			placeholder = placeholders.kill_enemies_boss
		elif 'id' in objective:
			# if !'label' in objective:
			interpolate_data.id_label = objective.id.replace('_', ' ').capitalize() 
			placeholder = placeholders.kill_enemies_id
		else:
			placeholder = placeholders.kill_enemies
	elif objective.type == 'survive_time':
		placeholder = placeholders.survive_time
		# if !'label'in objective:
		interpolate_data.value = Formatter.format_ellapsed(Formatter.format_timer_seconds(objective.value))
	elif objective.type == 'find_exit':
		placeholder = placeholders.find_exit
	else:
		push_error("Invalid objective type: " + objective.type)
		return null
	if 'label' in objective:
		placeholder = objective.label
	return tr(placeholder).format(interpolate_data)


func duplicate(_deep = false):
	return get_script().new(data)

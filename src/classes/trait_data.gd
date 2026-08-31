class_name TraitData

var data: Dictionary
var current_stack_length = 1


func _init(data_apply: Dictionary):
	data = data_apply.duplicate(true)


func _get(property):
	if !property in data:
		return null
	return data[property]


func _set(property: String, value):
	data[property] = value
	return true



func can_stack():
	if !'stack_max' in data && data.stack:
		return true
	if !data.stack:
		return false
	return current_stack_length < data.stack_max


func format_description():
	var texts = PoolStringArray()
	texts.append(format_description_rows())
	texts.append(format_stack())
	return texts.join("\n")


func format_stack():
	var text = ""
	if 'stack_max' in data:
		var size = Traits.get_current_size(data.uid)
		if size > 0:
			text += "\n\n%s: [color=green]%s/%s[/color]" % [tr('MAX_STACK'), size, data.stack_max] 
		else:
			text += "\n\n%s: [color=green]%s[/color]" % [tr('MAX_STACK'), data.stack_max] 
	return text


func format_description_rows():
	var texts = PoolStringArray()
	for index in data.description_rows.size():
		var row = data.description_rows[index]
		texts.append(tr(row))
	return texts.join("\n")


func duplicate(_deep = false):
	return get_script().new(data)

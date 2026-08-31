extends Reference
class_name ModifierData

var data: Dictionary
var host

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


# execute after apply modifiers for the first time
func added():
	host.emit_signal('modifier_added', self)


# execute when modifier are added and already exists
func update(_source_data):
	pass


# exute on modifier removed
func removed():
	host.emit_signal('modifier_removed', self)


# execute every time on host add/remove modifiers
func apply_modifiers():
	for key in host.modifier_keys:
		if !(key in host) || !key in self || self[key] == null:
			continue
		var value = host[key]
		var modifier = self[key]
		if typeof(modifier) == TYPE_STRING:
			if modifier.ends_with('%'):
				value += float(modifier) / 100 * value
			else:
				value += float(modifier)
		elif typeof(modifier) == TYPE_BOOL:
			value = modifier
		else:
			value += modifier
			
		host[key] = value


func duplicate(_deep = false):
	return get_script().new(data)

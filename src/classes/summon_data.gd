extends Reference
class_name SummonData

var data: Dictionary

func _init(data_apply: Dictionary):
	data = ConsumableHelper.sanitize_data(data_apply)


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


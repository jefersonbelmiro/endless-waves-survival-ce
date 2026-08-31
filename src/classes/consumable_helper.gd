class_name ConsumableHelper


static func sanitize_data(data_apply):
	var result = data_apply.duplicate(true) 
	if 'type' in result && typeof(result.type) == TYPE_STRING:
		result.type = FP.enum_value_from_string(Global.CONSUMABLE_TYPE, result.type)
	return result



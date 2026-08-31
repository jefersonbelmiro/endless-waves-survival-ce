class_name FP

const SAFE_TYPES = [TYPE_OBJECT, TYPE_ARRAY, TYPE_DICTIONARY]


static func safe_get(obj, path: String, default = null):
	var parts = path.split('.')
	var result = obj
	for key in parts:
		if !SAFE_TYPES.has(typeof(result)):
			return default
		if !result || !key in result || result[key] == null:
			return default
		result = result[key]
	return result 
	

# @FIXME why did I create this monster anyway?
static func safe_set(obj, path, value, create = true):
	if !SAFE_TYPES.has(typeof(obj)):
		return false
	var parts = path.split('.')
	var current = obj
	for index in parts.size():
		var key = parts[index]
		var last = index + 1 >= parts.size()
		if !SAFE_TYPES.has(typeof(current)):
			return false
		if last:
			if !create && !key in current:
				return false
			current[key] = value
		else:
			if !create && !key in current:
				return false
			if create && !key in current:
				current[key] = {}
			current = current[key]

	return true


static func merge_dictionary(source, patch):
	var result = source.duplicate(true)
	for key in patch:
		var value = patch[key]
		if typeof(value) == TYPE_DICTIONARY && key in result:
			value = merge_dictionary(result[key], value)
		elif typeof(value) == TYPE_ARRAY && key in result:
			value = result[key] + value
		result[key] = value
	return result


static func patch_dictionary(source, patch, recursive = true, depth = -1):
	var result = source.duplicate(true)
	for key in patch.keys():
		var value = patch[key] 
		if recursive && depth && typeof(value) == TYPE_DICTIONARY && key in result && typeof(result[key]) == TYPE_DICTIONARY :
			value = patch_dictionary(result[key], value, recursive, depth - 1)
		result[key] = value
	return result


static func increment_dictionary(source, patch):
	var result = source.duplicate(true)
	for key in patch:
		var value = patch[key] 
		if !key in result:
			result[key] = value
		elif typeof(value) == TYPE_DICTIONARY:
			result[key] = increment_dictionary(result[key], value)
		else:
			result[key] += value
	return result


static func calculate_scale_from_area(area: float, initial_area: float, initial_factor: float):
	var radius = area * 0.5
	var scale_factor = (radius / initial_area - 1) * initial_factor + initial_factor
	return Vector2(scale_factor, scale_factor)


static func enum_value_from_string(enums_array, enum_value, default = null):
	if typeof(enum_value) == TYPE_INT:
		return enum_value
	# JSON parse sometimes converto to float
	if typeof(enum_value) == TYPE_REAL:
		return int(enum_value)
	var keys = enums_array.keys()
	var key = enum_value.to_upper()
	var idx = keys.find(key)
	if idx == -1:
		return default
	return idx


static func is_bit_enabled(mask, index):
	return mask & (1 << index) != 0


static func enable_bit(mask, index):
	return mask | (1 << index)


static func disable_bit(mask, index):
	return mask & ~(1 << index)


static func average(numbers: Array) -> float:
	var sum := 0.0
	if numbers.size() == 0:
		return sum
	for n in numbers:
		sum += n
	return sum / numbers.size()



static func uuid_v4():
	var BYTE_MASK: int = 0b11111111
	# 16 random bytes with the bytes on index 6 and 8 modified
	var b = [
		randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
		randi() & BYTE_MASK, randi() & BYTE_MASK, ((randi() & BYTE_MASK) & 0x0f) | 0x40, randi() & BYTE_MASK,
		((randi() & BYTE_MASK) & 0x3f) | 0x80, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
		randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
	]
	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
		# low
		b[0], b[1], b[2], b[3],
		# mid
		b[4], b[5],
		# hi
		b[6], b[7],
		# clock
		b[8], b[9],
		# clock
		b[10], b[11], b[12], b[13], b[14], b[15]
	]

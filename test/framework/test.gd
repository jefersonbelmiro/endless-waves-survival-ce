extends Reference

var _fails = []
var _asserts = 0

var _types = {
	TYPE_BOOL: 'TYPE_BOOL',
	TYPE_STRING: 'TYPE_STRING',
	TYPE_INT: 'TYPE_INT',
	TYPE_DICTIONARY: 'TYPE_DICTIONARY',
	TYPE_ARRAY: 'TYPE_ARRAY',
	TYPE_REAL: 'TYPE_REAL'
}


func title() -> String:
	return ""


func assert_eq(value, expected):
	_asserts += 1
	if typeof(value) != typeof(expected):
		_build_fail("assert_eq", ["expected type {expected} to be type {value}".format({ "value": _get_type(value), "expected": _get_type(expected) }) ] )
	elif value != expected:
		_build_fail("assert_eq", ["expected {expected} to be {value}".format({ "value": value, "expected": expected }) ] )


func _get_type(value):
	var type = typeof(value)
	if _types.has(type):
		return _types[type]
	return type


func assert_contains(value, expected):
	_asserts += 1
	if typeof(value) != typeof(expected):
		_build_fail("assert_contains", ["expected type {expected} to be type {value}".format({ "value": _get_type(value), "expected": _get_type(expected) }) ] )

	if typeof(value) == TYPE_ARRAY || typeof(value) == TYPE_DICTIONARY:
		var diffs = _diff_dict(value, expected)
		if diffs.size():
			var details = []
			for index in diffs.size():
				var diff = diffs[index]
				details.append("%s: %s" % [diff.path, diff.label]) 
			_build_fail("assert_contains", details)


func _diff_dict(value, expected, base_path = "", result = []):
	var is_dict = typeof(expected) == TYPE_DICTIONARY
	var is_array = typeof(expected) == TYPE_ARRAY

	if !is_dict && !is_array:
		if typeof(expected) != typeof(value):
			var error = "expected type {expected} to be type {value}".format({ "value": _get_type(value), "expected": _get_type(expected) })
			result.append({ path = base_path, label = "diff type: " + error})
		elif expected != value:
			result.append({ path = base_path, label = "diff value(%s != %s)" % [value, expected]})
		return result

	var keys = expected.keys() if is_dict else expected.size()
	for index in keys:
		var path = str(index)
		if base_path:
			path = "%s.%s" % [base_path, index]
		var value_has_index = value.has(index) if is_dict else index <= value.size() - 1
		if !value_has_index:
			result.append({ path = path, label = "missing %s" % ["key" if is_dict else "index"]})
			continue

		if typeof(value[index]) != typeof(expected[index]):
			var error = "expected {expected_value}:{expected_type} to be {value}:{value_type}".format({ 
				"expected_type": _get_type(expected[index]),
				"value_type": _get_type(value[index]), 
			})
			result.append({ path = path, label = "diff type: " + error})
			continue

		if is_dict || is_array:
			_diff_dict(value[index], expected[index], path, result)
		elif value[index] != expected[index]:
			result.append({ path = path, label = "diff value(%s != %s)" % [value[index], expected[index]]})

	return result


func _build_fail(label = "", details = []):
	# only in debug mode get_stack() works
	var stack = get_stack()
	var result = PoolStringArray()
	if stack.size() >= 3:
		if label:
			label += " at line %s" % [stack[2].line]
		else:
			label += "at line %s" % [stack[2].line]
	if label:
		result.append(label)
	if details:
		var format_details = PoolStringArray(details)
		var separator = "      - "
		if label:
			result.append(separator + format_details.join("\n" + separator))
		else:
			result.append(format_details.join("\n" + separator))
	_fails.append(result.join("\n"))



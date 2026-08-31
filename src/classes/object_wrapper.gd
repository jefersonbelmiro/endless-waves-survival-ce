class_name ObjectWrapper

var object
var disabled_count = 0
var deferred = false
var disabled = false setget set_disabled


func _init(object_source, options = null):
	object = object_source
	if options && 'deferred' in options:
		self.deferred = options.deferred
	if options && 'disabled' in options:
		self.disabled = options.disabled


func _get(property):
	if !property in object:
		return null
	return object[property]


func _set(property: String, value):
	if !property in object:
		return false
	object[property] = value
	return true


func set_disabled(value: bool):
	if value:
		disabled_count += 1
	elif disabled_count > 0:
		disabled_count -= 1
	disabled = disabled_count > 0
	if deferred:
		object.set_deferred('disabled', disabled)
	else:
		object.disabled = disabled

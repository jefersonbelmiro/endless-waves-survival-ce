class_name Behaviour

signal disabled_changed(_disabled)

var group_id = "default"
var container: BehaviourContainer
var host: Node2D
var id: String

var disabled = false setget set_disabled
var disabled_count = 0


func set_disabled(value: bool):
	disabled_count += 1 if value else -1
	if disabled_count < 0:
		disabled_count = 0
	var new_value = disabled_count > 0 
	var diff = disabled != new_value
	disabled = new_value
	if diff:
		emit_signal("disabled_changed", new_value)


func disable_others_in_group():
	container.disable_group(group_id, [id])


func enable_others_in_group():
	container.enable_group(group_id, [id])

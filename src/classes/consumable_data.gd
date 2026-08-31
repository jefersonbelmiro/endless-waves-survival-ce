extends ModifierData
class_name ConsumableData

var icon_node
var timer: float = -1
var current_stack_length = 1


func _init(data_apply: Dictionary).(data_apply):
	data = ConsumableHelper.sanitize_data(data_apply)


func _process(delta):
	if !icon_node || timer == -1:
		return
	timer -= delta
	icon_node.set_progress(timer, data.modifier_duration)
	if timer <= 0:
		host.remove_modifier(data.id)


func added(): 
	icon_node = Global.hud_consumable_slots.add(data)
	timer = float(data.modifier_duration)
	icon_node.set_progress(timer, timer)


func update(source_data):
	_apply_stack(source_data)
	timer = data.modifier_duration
	if icon_node:
		icon_node.set_progress(timer, timer)
		icon_node.set_label_value(current_stack_length)


func removed(): 
	if icon_node:
		Global.hud_consumable_slots.release_slot(data)


func can_use(host_ = host):
	# has modifier and can't stack
	if host_.modifiers.has(data.id) && !host_.modifiers.get(data.id).can_stack():
		return false
	return true


func can_stack():
	if !'stack_max' in data && data.stack:
		return true
	if !data.stack:
		return false
	return current_stack_length < data.stack_max


func _apply_stack(stack_data):
	if !can_stack():
		return
	current_stack_length += 1
	Global.apply_modifier_stack(self, stack_data, host.modifier_keys)


func format_description():
	var text = tr(data.description).format(DataFormatter.it_data(data, { ignore_sign = ['modifier_duration'] }))
	if 'stack_max' in data:
		if is_instance_valid(Global.player) && Global.player.stats.modifiers.has(data.id):
			var updated_stack_length = Global.player.stats.modifiers[data.id].current_stack_length
			text += "\n\n%s: [color=green]%s/%s[/color]" % [tr('MAX_STACK'), updated_stack_length, data.stack_max] 
		else:
			text += "\n\n%s: [color=green]%s[/color]" % [tr('MAX_STACK'), data.stack_max] 
	return text


func format_toast_used():
	return tr(data.toast_used).format(DataFormatter.it_data(data)) 


func format_toast_cant_use():
	if 'toast_cant_use' in data:
		return tr(data.toast_cant_use)
	return null

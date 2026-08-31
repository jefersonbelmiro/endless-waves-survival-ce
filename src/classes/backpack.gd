class_name Backpack

var size: int
var data = []
var host

var data_cache = {}

func _init(host_):
	host = host_


func load():
	var persistent_data = Persistent.get_backpack()
	size = persistent_data.size
	data.resize(size)
	data.fill({ size = 0, id = null })
	for index in persistent_data.data.size():
		var curr = persistent_data.data[index]
		data[index] = curr
		if curr.id:
			data_cache[curr.id] = Entities.create_consumable_data(curr.id) 


func use(index: int):
	if index > data.size() - 1 || data.size() == 0:
		return false
	var item = data[index]

	if item.size <= 0:
		item.id = null
		return false

	var id = item.id
	if !get_data(id).can_use(Global.player.stats):
		var error_message = get_data(id).format_toast_cant_use()
		if error_message:
			Global.add_toast_warn(error_message)
		return false

	item.size -= 1
	host.add_consumable(get_data(id))
	var toast_used = host.stats.modifiers.get(id).format_toast_used()
	if toast_used:
		Global.add_toast(tr(host.stats.modifiers.get(id).format_toast_used()))
	SFX.add_consumable(id)
	Global.log_use_consumable(id)

	# @FIXME force update to instant use consumable
	host.stats._apply_modifiers()

	if item.size < 0:
		item.id = null
	return true


func add(id: String):
	var add_index = -1
	for index in size:
		if data[index].id == id && data[index].size > 0:
			add_index = index
			break
		elif add_index == -1 && data[index].size == 0:
			add_index = index
			
	if add_index != -1:
		var curr_data = data[add_index]
		if curr_data.size > 0:
			curr_data.size += 1
		else:
			data[add_index] = { size = 1, id = id }
	else:
		# max stack, just ignore
		# @FIXME now consumable are lost, its right?
		if !get_data(id).can_use(Global.player.stats):
			var error_message = get_data(id).format_toast_cant_use()
			if error_message:
				Global.add_toast_warn(error_message)
			return false
		host.add_consumable(get_data(id))
		var toast_used = host.stats.modifiers.get(id).format_toast_used()
		if toast_used:
			Global.add_toast(tr(host.stats.modifiers.get(id).format_toast_used()))
		SFX.add_consumable(id)
		# @FIXME force update to instant use consumable
		host.stats._apply_modifiers()


func get_data(id: String):
	if !data_cache.has(id):
		data_cache[id] = Entities.create_consumable_data(id)
	return data_cache.get(id)


func duplicate(deep = false):
	var instance = get_script().new(host)
	instance.data = data.duplicate(deep)
	instance.size = size
	return instance



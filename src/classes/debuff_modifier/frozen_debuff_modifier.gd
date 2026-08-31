extends DebuffModifierData
class_name FrozenDebuffModifier 

var icon_node
var current_modifier_duration = 5

func _init(data_apply: Dictionary = {}).(data_apply):
	 data = FP.patch_dictionary({
		id = 'debuff_frozen',
		icon = Global.icon_frozen,
		proc_chance = 1.0,
		modifier_duration = 1.0,
		type = "debuff",
	}, data_apply)


func _process(delta):
	if timer == -1:
		return
	timer -= delta
	if icon_node:
		icon_node.set_progress(timer, current_modifier_duration)
	if timer <= 0:
		host.remove_modifier(data.id)


func added(): 
	current_modifier_duration = _get_modifier_duration() 
	timer = current_modifier_duration
	if !current_modifier_duration:
		return
	if host.parent == Global.player:
		icon_node = Global.hud_consumable_slots.add(data)
		icon_node.self_modulate = Color("#bf4e4e")
		icon_node.set_progress(timer, current_modifier_duration)
	# emit signal
	.added()


# refresh duration and if new data modifier_duration is hight, set this
func update(source_data):
	# set hight modifier_duration
	data.modifier_duration = max(source_data.modifier_duration, data.modifier_duration)
	current_modifier_duration = _get_modifier_duration() 
	timer = current_modifier_duration
	if icon_node:
		icon_node.set_progress(timer, current_modifier_duration)


func removed(): 
	if icon_node:
		Global.hud_consumable_slots.release_slot(data)
	.removed()

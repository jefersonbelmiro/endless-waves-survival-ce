extends DebuffModifierData
class_name BurnDebuffModifier 

var elapsed_time = 0.0
var icon_node
var current_modifier_duration = 5
var initial_damage = 1

func _init(data_apply: Dictionary = {}).(data_apply):
	data = FP.patch_dictionary({
		id = 'debuff_burn',
		icon = Global.icon_burn,
		proc_chance = 1.0,
		modifier_duration = 5,
		type = "debuff",
		damage = 1.0,
		description = "DEBUFF_BURN_DESC",
	}, data_apply)
	initial_damage = data.damage


func _process(delta):
	if timer == -1:
		return
	elapsed_time += delta
	if elapsed_time > 1:
		elapsed_time = 0
		host.parent.hurt_box.hitted({
			source_id = data.id,
			target_node = host,
			damage_type = Global.DAMAGE_TYPE.MAGIC,
			damage = data.damage,
			mute_sfx = true,
		})
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


# stack damage and refresh duration
func update(source_data):
	# set hight modifier_duration
	if 'modifier_duration' in source_data:
		data.modifier_duration = max(source_data.modifier_duration, data.modifier_duration)

	if !'stack' in source_data || source_data.stack:
		if "damage" in source_data:
			data.damage += source_data.damage
		else:
			data.damage += initial_damage
	current_modifier_duration = _get_modifier_duration() 
	timer = current_modifier_duration
	if icon_node:
		icon_node.set_progress(timer, current_modifier_duration)
		icon_node.set_label_value(data.damage)


func removed(): 
	if icon_node:
		Global.hud_consumable_slots.release_slot(data)
	.removed()

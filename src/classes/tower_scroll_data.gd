extends ConsumableData
class_name TowerScrollData

var card_id: String


func _init(data_apply: Dictionary).(data_apply):
	card_id = data.id.replace("consumable_", "").replace("_scroll", "")


func added(): 
	host.owner.add_summon(card_id)


func removed(): pass
func apply_modifiers(): pass


func update(_source_data):
	current_stack_length += 1
	host.owner.add_summon(card_id)


func format_toast_used():
	return null


func format_toast_cant_use():
	var card_label = "[color=black]%s[/color]" % [tr("CARD_ICE_TOWER_LABEL")]
	return tr(data.toast_cant_use).format({ card_label = card_label }) 


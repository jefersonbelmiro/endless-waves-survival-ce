extends Behaviour
class_name DebuffBurnBehaviour

func _init():
	group_id = "debuff"


func _ready():
	var effect_node = Global.create_debuff_burn_effect()
	host.call_deferred('add_child', effect_node)


func _exit_tree():
	var effect_node = host.get_node_or_null('debuff_burn_effect')
	if effect_node:
		host.call_deferred('remove_child', effect_node)

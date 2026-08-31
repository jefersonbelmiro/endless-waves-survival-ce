extends Behaviour
class_name DebuffFrozenBehaviour

func _init():
	group_id = "debuff"


func _ready():
	host.velocity = Vector2.ZERO
	var frozen_effect_node = Global.create_frozen_effect()
	host.call_deferred('add_child', frozen_effect_node)
	container.disable_group("move")
	container.disable_group("attack")
	host.sprite.frame = 0


func _exit_tree():
	var frozen_effect_node = host.get_node_or_null('frozen_effect')
	if frozen_effect_node:
		host.call_deferred('remove_child', frozen_effect_node)
	container.enable_group("move")
	container.enable_group("attack")

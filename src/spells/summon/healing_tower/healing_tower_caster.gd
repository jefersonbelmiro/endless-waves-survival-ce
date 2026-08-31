extends BaseCaster

var scene = preload("res://src/spells/summon/healing_tower/healing_tower.tscn")

func cast():
	var node = scene.instance()
	node.id = data.id
	node.global_position = caster.global_position + caster.direction.normalized() * 20
	node.data = get_data()
	node.invoker = node
	node.summoner = invoker
	Global.add_entity_deferred(node)

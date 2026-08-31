extends BaseCaster


func _ready():
	caster.stats.add_modifier(data, true)


func upgrade(next_level = null):
	.upgrade(next_level)
	caster.stats.apply_modifiers()

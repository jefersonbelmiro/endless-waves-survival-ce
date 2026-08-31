extends Node

var parent: Player

var casters = {}

func _ready():
	parent = get_parent()


func add_caster(id: String):
	if casters.has(id):
		return casters[id]
	var caster = Entities.create_caster(id)

	# @DEPRECATED
	# @SEE invoker property
	caster.caster = parent
	caster.invoker = parent

	casters[caster.id] = caster
	add_child(caster)
	# call_deferred('add_child', caster)
	Global.log_spell_level(id, 1)
	return caster


func remove_caster(id: String):
	var node = get_node_or_null(id)
	var data = casters[id].get_data()

	Global.hud_spell_slots.release_slot(data)
	casters.erase(id)
	Global.log_spell_level(id, 0)

	if node:
		remove_child(node)

	# remove ultimate modifiers
	if parent.stats.modifiers.has(id):
		parent.stats.remove_modifier(id)


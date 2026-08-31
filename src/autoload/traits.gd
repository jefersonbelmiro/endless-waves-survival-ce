extends Node

signal current_changed

var avaliable = [
	PolitePerilTraitData.new(),
	ExtendedHarvestTraitData.new(),
	TreasureHunterTraitData.new(),
	MagneticMayhemTraitData.new(),
	GlassCannonTraitData.new(),
	NaturesPactTraitData.new(),
	SlowTimeBubbleTraitData.new(),
	BloodBargainTraitData.new(),
	RiskyRichesTraitData.new(),
	BattleScholarTraitData.new(),
]

var avaliable_data = {}

var max_slots = 20

var current = [] setget set_current
var current_edit = null

func _ready():
	if Persistent.loaded:
		_on_persistent_loaded()
	else:
		Persistent.connect("loaded", self, "_on_persistent_loaded")
	Persistent.connect("changed", self, "_on_persistent_changed")


func set_current(value):
	current = value
	emit_signal('current_changed')


func start_current_edit():
	current_edit = current.duplicate(true)
	return current_edit


func end_current_edit():
	current = current_edit
	current_edit = null


func reset():
	current = []


func _on_persistent_loaded():
	for index in avaliable.size():
		var data = avaliable[index].duplicate(true)
		avaliable_data[data.uid] = data
	_on_persistent_changed()


func _on_persistent_changed():
	current = Persistent.get_traits()
	current.resize(max_slots)
	for index in max_slots:
		if current[index] && !current[index].id in avaliable_data:
			current[index] = { size = 0, id = null }
		elif !current[index] || current[index].size == 0:
			current[index] = { size = 0, id = null }


func get_player_stats():
	var stats = {}
	for index in current.size():
		var trait = current[index]
		if !trait.size || !trait.id:
			continue
		var trait_data = avaliable_data.get(trait.id).duplicate(true)
		if 'player_stats' in trait_data:
			Global.apply_trait_stack(stats, trait_data.player_stats, trait.size)
	# @TODO add modifier to player to keep tratis buff/debuff on new stats
	# current add only on start
	return stats


func get_enemy_stats():
	var stats = {}
	for index in current.size():
		var trait = current[index]
		if !trait.size || !trait.id:
			continue
		var trait_data = avaliable_data.get(trait.id).duplicate(true)
		if 'enemy_stats' in trait_data:
			Global.apply_trait_stack(stats, trait_data.enemy_stats, trait.size)
	return stats


func apply_player_stats(node: Node2D):
	_apply_stats(node, get_player_stats())


func apply_enemy_stats(node: Node2D):
	_apply_stats(node, get_enemy_stats())


func get_max_stack(trait_id: String):
	return avaliable_data.get(trait_id).stack_max


func get_current_size(trait_id: String):
	var trait_data = null
	var items = current_edit if current_edit else current
	for index in items.size():
		var trait = items[index]
		if trait.id == trait_id:
			trait_data = trait
			break
	if !trait_data:
		return 0
	return trait_data.size


func get_chest_factor():
	var factor := 0.0
	for index in current.size():
		var trait = current[index]
		if !trait.size || !trait.id:
			continue
		var trait_data = avaliable_data.get(trait.id).duplicate(true)
		if 'chest_factor' in trait_data:
			factor += trait_data.chest_factor * trait.size
	return factor


func get_spawn_factor():
	var factor := 0.0
	for index in current.size():
		var trait = current[index]
		if !trait.size || !trait.id:
			continue
		var trait_data = avaliable_data.get(trait.id).duplicate(true)
		if 'spawn_factor' in trait_data:
			factor += trait_data.spawn_factor * trait.size
	return factor


func _apply_stats(node, stats: Dictionary):
	for key in stats.keys():
		var value = node.stats[key]
		var modifier = stats[key]
		if typeof(modifier) == TYPE_STRING:
			if modifier.ends_with('%'):
				value += float(modifier) / 100 * value
			else:
				value += float(modifier)
		elif typeof(modifier) == TYPE_BOOL:
			value = modifier
		else:
			value += modifier

		if node.stats.modifier_keys.has(key):
			node.stats.set_raw_value(key, value)
		else:
			node.stats[key] = value



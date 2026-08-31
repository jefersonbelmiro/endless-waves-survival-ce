extends Node

var spells_data = []
var spells_data_map = {}
var consumables_data = []
var consumables_data_map = {}
var chars_data = []
var chars_data_map = {}
var maps_data = []
var maps_data_map = {}


func _ready():
	spells_data = _get_spells_data()
	consumables_data = _get_consumables_data()
	maps_data = _get_maps_data()
	chars_data = _get_chars_data()


func create_caster(id: String):
	var data = create_spell_data(id)
	var scene
	if data.cast_type == Global.SKILL_CAST_TYPE.PASSIVE:
		scene = Global.passive_caster_scene
	else:
		var base_path = Global.SKILL_CAST_TYPE.keys()[data.cast_type].to_lower()
		scene = load("res://src/spells/%s/%s/%s_caster.tscn" % [base_path, id, id])
	var instance = scene.instance()
	data.level = 1
	instance.id = id
	instance.data = data
	instance.name = id
	return instance


func create_spell_data(id: String):
	var spell_data = Database.get_spell(id)
	if 'class' in spell_data:
		return spell_data.class.new(spell_data)
	if spell_data.cast_type == 'passive' || int(spell_data.cast_type) == Global.SKILL_CAST_TYPE.PASSIVE:
		return PassiveCardData.new(spell_data)
	return CardData.new(spell_data)


func create_consumable_data(consumable_id: String):
	var consumable_data = Database.get_consumable(consumable_id)
	if 'class' in consumable_data:
		return consumable_data.class.new(consumable_data)
	if consumable_data.type == 'summon' || int(consumable_data.type) == Global.SKILL_CAST_TYPE.PASSIVE:
		return SummonData.new(consumable_data)
	return ConsumableData.new(consumable_data)


func create_modifier_data(modifier_data):
	if 'class' in modifier_data:
		var script = modifier_data.class
		if typeof(modifier_data.class) == TYPE_STRING:
			# @FIXME preload class resources
			script = load(modifier_data.class)
		return script.new(modifier_data)
	elif 'type' in modifier_data && modifier_data.type == 'debuff':
		# @FIXME preload class resources
		var script = load("res://src/classes/debuff_modifier_data.gd")
		return script.new(modifier_data)
	return ModifierData.new(modifier_data)


func create_char_data(char_id: String):
	var raw_data = Database.get_char(char_id)
	if 'class' in raw_data:
		return raw_data.class.new(raw_data)
	return CharData.new(raw_data)


func create_map_data(map_id: String):
	var raw_data = Database.get_map(map_id)
	if 'class' in raw_data:
		return raw_data.class.new(raw_data)
	return MapData.new(raw_data)


func get_spells_data():
	return spells_data


func get_consumables_data():
	return consumables_data


func get_chars_data():
	return chars_data


func get_maps_data():
	return maps_data


func _sort_handler(a, b):
	return b.sort_order > a.sort_order


func _sort_spell_handler(a, b):
	return _get_spell_sort_order(b) > _get_spell_sort_order(a)


func _get_spell_sort_order(spell_data):
	match spell_data.cast_type:
		Global.SKILL_CAST_TYPE.ULTIMATE:
			return spell_data.sort_order + 500
		Global.SKILL_CAST_TYPE.PASSIVE:
			return spell_data.sort_order + 1000
		Global.SKILL_CAST_TYPE.SUMMON:
			return spell_data.sort_order + 1500
	return spell_data.sort_order


func _get_spells_data():
	var result = []
	var spells_raw = Database.get_spells()
	for spell_data in spells_raw:
		var data =  create_spell_data(spell_data.id)
		spells_data_map[data.id] = data
		result.append(data)
	result.sort_custom(self, "_sort_spell_handler")
	return result


func _get_consumables_data():
	var result = []
	var consumables_raw = Database.get_consumables()
	for consumable_data in consumables_raw:
		var data
		if 'class' in consumable_data:
			data = consumable_data.class.new(consumable_data)
		else:
			data = ConsumableData.new(consumable_data)
		consumables_data_map[data.id] = data
		result.append(data)
	result.sort_custom(self, "_sort_handler")
	return result


func _get_maps_data():
	var result = []
	var maps_raw = Database.get_maps()
	for raw in maps_raw:
		var data = create_map_data(raw.id)
		maps_data_map[data.uid] = data
		result.append(data)
	result.sort_custom(self, "_sort_handler")
	return result


func _get_chars_data():
	var result = []
	var chars_raw = Database.get_chars()
	for raw in chars_raw:
		var data = create_char_data(raw.id)
		chars_data_map[data.id] = data
		result.append(data)
	result.sort_custom(self, "_sort_handler")
	return result


extends Node
class_name DropSystem

var consumables = []
var consumables_tier_1 = []
var consumables_tier_2 = []
var consumables_tier_3 = []
var deck_cards = {}
var active = true
var drop_exp = true

func _ready():
	randomize()
	Global.connect("enemy_died", self, '_on_enemy_died')
	Global.connect('player_upgrade_points_changed', self, '_on_player_upgrade_points_changed')

	for consumable in Database.get_consumables():
		if 'droppable' in consumable && !consumable.droppable:
			continue
		consumables.append(consumable)
		if consumable.tier == 1:
			consumables_tier_1.append(consumable)
		elif consumable.tier == 2:
			consumables_tier_2.append(consumable)
		elif consumable.tier == 3:
			consumables_tier_3.append(consumable)

	var max_drop_timer = Timer.new()
	max_drop_timer.wait_time = 5
	max_drop_timer.autostart = true
	max_drop_timer.connect("timeout", self, "_on_max_drop_timer_timeout")
	add_child(max_drop_timer)

	var _current_deck = Persistent.get_deck(Global.session.current_deck_id)
	for card_id in _current_deck.cards.keys():
		var card_data = Entities.create_spell_data(card_id)
		CardHelper.set_deck(card_data, _current_deck)
		deck_cards[card_id] = card_data


func stop():
	active = false
	

func start():
	active = true

	
func _on_enemy_died(enemy):
	if !active || !is_instance_valid(Global.player) || !Global.player.is_alive():
		return
	var drops = _get_drops(enemy)
	if drops.size() > 0:
		Global.drop_radius(drops, enemy.global_position)


func _get_drops(enemy):
	var drops = []
	if !'drops' in enemy:
		return drops
	for id in enemy.drops.keys():
		var drop = enemy.drops[id]
		var proc_chance = drop.proc_chance
		if Global.player.stats.drop_proc_chance_factor:
			proc_chance += drop.proc_chance * Global.player.stats.drop_proc_chance_factor

		if id == 'experience' && !drop_exp:
			continue
		if proc_chance <= 0:
			continue
		if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
			var drop_data = _get_drop_data(id)
			if !drop_data:
				continue
			if 'value' in drop:
				drop_data.value = drop.value
			drops.append(drop_data)
	return drops


func _get_drop_data(id: String):
	if id == 'experience':
		return {
			id = id,
			group = 'experiences',
			texture = Global.experience_texture 
		}
	elif id == 'coin':
		return {
			id = id,
			group = 'coins',
			texture = Global.coin_texture  
		}
	elif id == 'consumable':
		var consumable = consumables[randi() % consumables.size()]
		return {
			id = consumable.uid,
			group = 'consumables',
			texture = consumable.icon  
		}
	elif id == 'consumable_tier_1':
		var consumable = consumables_tier_1[randi() % consumables_tier_1.size()]
		return {
			id = consumable.uid,
			group = 'consumables',
			texture = consumable.icon  
		}
	elif id == 'consumable_tier_2':
		var consumable = consumables_tier_2[randi() % consumables_tier_2.size()]
		return {
			id = consumable.uid,
			group = 'consumables',
			texture = consumable.icon  
		}
	elif id == 'consumable_tier_3':
		var consumable = consumables_tier_3[randi() % consumables_tier_3.size()]
		return {
			id = consumable.uid,
			group = 'consumables',
			texture = consumable.icon  
		}
	elif id == 'chest':
		return {
			id = id,
			group = 'chests',
			texture = Global.chest_texture  
		}
	push_error('Invalid drop id: ' + id)


func _process_max_drop(group: String, max_size: int):
	var nodes = get_tree().get_nodes_in_group(group)
	if nodes.size() <= max_size:
		return
	var size = nodes.size() - max_size
	for index in size:
		if is_instance_valid(nodes[index]):
			nodes[index].queue_free()


func _on_max_drop_timer_timeout():
	_process_max_drop('experiences', 500)
	_process_max_drop('coins', 300)
	_process_max_drop('consumables', 30)
	_process_max_drop('chests', 10)


func _on_player_upgrade_points_changed():
	var _avaliable_cards = []
	for data_id in deck_cards.keys():
		var data = deck_cards[data_id]
		if Global.player.spells.has(data.id):
			data = Global.player.get_card_data(data.id)
			if !data.has_upgrade():
				continue
		elif data.cast_type != Global.SKILL_CAST_TYPE.PASSIVE && !Global.hud_spell_slots.can_add(data):
			continue
		_avaliable_cards.append(data)
		
	if _avaliable_cards.size() == 0:
		drop_exp = false
		Global.disconnect('player_upgrade_points_changed', self, '_on_player_upgrade_points_changed')
		

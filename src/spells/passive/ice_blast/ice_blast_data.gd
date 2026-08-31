extends PassiveCardData
class_name IceBlastData

var _color = Color('#458cd6')


func _init(data_apply: Dictionary).(data_apply):
	pass


# no property to apply modifier
func apply_modifiers():
	pass


func added(): 
	.added()
	Global.connect("enemy_died", self, "_on_enemy_died")


func _on_enemy_died(enemy):
	if !is_instance_valid(enemy) || !enemy.stats.modifiers.has("debuff_frozen"):
		return
	if data.proc_chance < 1 && rand_range(0, 1) > data.proc_chance:
		return
	var hit_data = {
		source_node = caster,
		source_id = data.id,
		area = get_area(),
		damage = data.damage,
		damage_knockback = data.damage_knockback,
		damage_type = data.damage_type,
	}
	Global.add_hit_box_area(enemy.global_position, hit_data, "enemy_hurtbox")
	Global.add_floor_hit_effect(enemy.global_position, get_area(), _color)
	SFX.add_explosion_short_soft({ ref_node = enemy })


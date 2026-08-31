extends TowerSummonBase

var nodes = {}
var healing_initial_area: float = 50
var healing_initial_factor: float = 0.5

onready var healing_sprite = $healing_sprite

func _ready():
	var scale = FP.calculate_scale_from_area(data.area, healing_initial_area, healing_initial_factor)
	healing_sprite.scale = scale + Vector2(0, -scale.y * 0.3)
	$healing_area/collision_shape_2d.shape.radius = data.area * 0.5


func die():
	.die()
	if 'explosion' in data && data.explosion:
		var explosion_area = data.get_area()
		var hit_data = {
			source_node = caster.invoker,
			source_id = 'shield_explosion',
			area = explosion_area,
			damage = data.explosion_damage,
			damage_knockback = data.damage_knockback,
			damage_type = Global.DAMAGE_TYPE.MAGIC,
		}
		Global.add_hit_box_area(global_position, hit_data, "enemy_hurtbox")
		Global.add_floor_hit_effect(global_position, explosion_area, base_color)
		SFX.add_explosion_short({ ref_node = self })


func _on_healing_area_body_entered(body):
	if body == self:
		return
	nodes[body] = true


func _on_healing_area_body_exited(body):
	nodes.erase(body)


func _on_healing_timer_timeout():
	var invalids = []

	var show_area_sprite = false

	for node in nodes.keys():
		if !is_instance_valid(node):
			invalids.append(node)
			continue
		if node.stats.current_health >= node.stats.max_health:
			continue
		show_area_sprite = true
		node.stats.current_health += data.health_healing
		node.stats.emit_signal("health_changed")
		Global.add_floating_text("+%s" % [data.health_healing], node.global_position, Color.green)

	for index in invalids.size():
		nodes.erase(invalids)

	if show_area_sprite:
		healing_sprite.stop()
		healing_sprite.show()
		healing_sprite.frame = 0
		healing_sprite.play()


func _on_healing_sprite_animation_finished():
	healing_sprite.stop()
	healing_sprite.frame = 0
	healing_sprite.hide()

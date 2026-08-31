extends Behaviour
class_name ExplosionAttackBehaviour

var area = 100
var color = Color("#ed3e3e") 
var damage_knockback = 100
var damage: float
var collision_radius: int

var _hit_box
var _exploding = false


func _init():
	group_id = "attack"


func _ready():
	if !damage:
		damage = host.stats.base_damage
	if !collision_radius:
		collision_radius = host.get_node("hurt_box/collision_shape_2d").shape.radius 
	_hit_box = Global.create_hit_box_melee({ disabled = disabled, collision_radius = collision_radius, collision_mask = "player_hurtbox" })
	_hit_box.connect("area_entered", self, "_on_hit_box_area_entered")
	host.add_child(_hit_box)
	connect("disabled_changed", self, "_on_disabled_changed")
	host.stats.connect("deaded", self, "_on_host_deaded")


func _on_hit_box_area_entered(_area):
	if disabled || _exploding:
		return
	_explode()


func _on_host_deaded():
	if disabled || _exploding:
		return
	_explode()


func _explode():
	_exploding = true
	# _hit_box.collision.set_deferred('disabled', true)
	host.base_color = color
	host.die()

	var hit_data = {
		source_node = host,
		source_id = id,
		area = area,
		damage = damage,
		damage_knockback = damage_knockback,
		damage_type = Global.DAMAGE_TYPE.PHYSICAL,
	}
	Global.add_hit_box_area(host.global_position, hit_data, ["player_hurtbox", "enemy_hurtbox"], [host])
	Global.add_floor_hit_effect(host.global_position, area, color)
	SFX.add_explosion_short({ ref_node = host })
	

func _on_disabled_changed(disabled: bool):
	_hit_box.collision.set_deferred('disabled', disabled)



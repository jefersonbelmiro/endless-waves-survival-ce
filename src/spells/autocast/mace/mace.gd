extends Position2D

signal timeout()

onready var pivot = $pivot

var caster: BaseCaster
var spell_data
var pivot_height = 0
var duration_end = false
var projectile_speed: float
var throw_speed: float = 300

onready var chain = $pivot/chain


func _ready():
	spell_data = caster.get_data()
	if 'duration' in spell_data && spell_data.duration > 0:
		$duration_timer.start(caster.get_duration())
	
	pivot_height = -spell_data.get_area()
	pivot.position.y = pivot_height * 0.2
	
	var chain_scale: float = 0.3
	var chain_height: float = pivot_height/chain_scale + 40
	chain.region_rect = Rect2(0, 0, 12, 0)
	chain.offset.y = 0

	var chain_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	chain_tween.tween_method(self, '_tween_chain', 0.0, 1.0, 0.5, [chain_height])


func _physics_process(delta):
	if caster.invoker.is_dead():
		queue_free()
		return
	rotation_degrees += (delta * projectile_speed)
	if !duration_end && pivot.position.y > pivot_height:
		pivot.position.y -= (delta * throw_speed)
	elif duration_end && pivot.position.y < pivot_height * 0.2:
		chain.hide()
		pivot.position.y += (delta * throw_speed)
	elif pivot.position.y >= pivot_height * 0.2:
		emit_signal('timeout')
		queue_free()


func _tween_chain(weight: float, chain_height: float):
	chain.region_rect = Rect2(0, 0, 12, chain_height * weight)
	chain.offset.y = chain_height / 2 * weight


func _on_hit_box_area_entered(area_obj):
	if !caster.invoker.is_alive():
		queue_free()
		return
	var data = {
		source_id = spell_data.id,
		target_node = area_obj.get_parent(),
		damage_type = spell_data.damage_type,
		damage = spell_data.damage,
		damage_knockback = spell_data.damage_knockback,
		position = pivot.global_position,
	}
	var hit_data = caster.invoker.stats.hit(data)
	area_obj.hitted(hit_data)


func _on_duration_timer_timeout():
	duration_end = true


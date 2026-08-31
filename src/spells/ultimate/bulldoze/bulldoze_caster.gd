extends BaseCaster

var cooldown_elapsed: float = 0
var casting = false
var allow_cast = false
var hit_box

onready var duration_timer = $duration_timer

func _input(event: InputEvent) -> void:
	if allow_cast && event.is_action_pressed(icon_node.action_name):
		cast()


func _process(delta: float):
	if !can_cast():
		return

	var cooldown = get_cooldown()
	if cooldown > 0:
		cooldown_elapsed += delta

	if !allow_cast && !casting && cooldown_elapsed >= cooldown:
		allow_cast = true
		SFX.add_ultimate_on()

	if casting:
		update_cooldown(cooldown)
	else:
		update_cooldown(cooldown - cooldown_elapsed)


func cast():
	if !allow_cast || casting || !caster.is_alive() || caster.is_disabled():
		return
	if cooldown_elapsed < get_cooldown():
		return
	if caster.is_channeling():
		caster.state = caster.STATES.IDLE
	casting = true
	var tween = create_tween().bind_node(caster).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(caster, 'scale', Vector2(1.6, 1.6), 0.3)
	caster.set_ultimate_buff_effect(true)
	caster.stats.add_modifier({ 
		id = id, 
		defense = data.defense,
		status_resistance = data.status_resistance, 
		move_speed = data.move_speed,
		minimal_damage = -1,
	})
	caster.stats.apply_modifiers()
	duration_timer.start(get_duration())
	SFX.add_powerup()

	if data.damage_knockback:
		if !hit_box:
			hit_box = Global.create_hit_box_melee({ 
				collision_radius = caster.hurt_box_collision.shape.radius,
				collision_mask = "enemy_hurtbox",
				disabled = false
			})
			hit_box.connect("area_entered", self, "_on_hit_box_area_entered")
			caster.add_child(hit_box)
		else:
			hit_box.disabled = false


func _on_duration_timer_timeout():
	casting = false
	allow_cast = false
	cooldown_elapsed = 0
	var tween = create_tween().bind_node(caster).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(caster, 'scale', Vector2(1, 1), 0.3)
	caster.set_ultimate_buff_effect(false)
	caster.stats.remove_modifier(id)
	caster.stats.apply_modifiers()
	reset_cooldown()

	if hit_box:
		hit_box.disabled = true


func _on_hit_box_area_entered(area_obj):
	var hit_data = {
		source_id = data.id,
		source_node = caster,
		target_node = area_obj.get_parent(),
		damage_type = Global.DAMAGE_TYPE.PHYSICAL,
		attack_type = Global.ATTACK_TYPE.MELEE,
		base_damage_factor = data.base_damage_factor,
		damage_knockback = data.damage_knockback,
		position = caster.global_position,
	}
	hit_data = caster.stats.hit(hit_data)
	area_obj.hitted(hit_data)
	



extends BaseCaster

var cooldown_elapsed: float = 0
var casting = false
var allow_cast = false
var hit_box

onready var duration_timer = $duration_timer
onready var ghost_timer = $ghost_timer


func _input(event: InputEvent) -> void:
	if allow_cast && event.is_action_pressed("cast_dash"):
		cast()


func _process(delta: float):
	if !invoker.is_alive():
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
	if !allow_cast || casting || !invoker.is_alive() || invoker.is_disabled():
		return
	if cooldown_elapsed < get_cooldown():
		return
	if invoker.is_channeling():
		invoker.state = invoker.STATES.IDLE
	casting = true
	# @FIXME
	invoker.accerelation = int(data.move_speed)
	invoker.stats.add_modifier({ id = id, move_speed =  data.move_speed })
	invoker.stats.apply_modifiers()
	duration_timer.start(get_duration())
	ghost_timer.start()
	SFX.add_dash()

	invoker.sprite.modulate = Color(0, 0, 0, 0.5)
	invoker.set_hurt_box_disabled(true)
	invoker.set_body_collision_layer("player_dashing")

	if data.base_damage_factor:
		if !hit_box:
			hit_box = Global.create_hit_box_melee({ 
				collision_radius = invoker.hurt_box_collision.shape.radius,
				collision_mask = "enemy_hurtbox",
				disabled = false
			})
			hit_box.connect("area_entered", self, "_on_hit_box_area_entered")
			invoker.add_child(hit_box)
		else:
			hit_box.disabled = false


func _create_ghost():
	var node = AnimatedSprite.new()
	node.scale = invoker.scale
	node.modulate = Color.black #invoker.color + Color(-0.7, -0.7, -0.7) # Color('#261232')
	node.global_position = invoker.global_position
	node.frames = invoker.sprite.frames
	node.animation = invoker.sprite.animation
	node.frame = invoker.sprite.frame
	node.flip_h = invoker.sprite.flip_h
	node.flip_v = invoker.sprite.flip_v
	Global.game.add_child(node)
	var tween = node.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(node, 'modulate:a', 0.0, 0.5)
	tween.connect("finished", node, 'queue_free')


func _on_duration_timer_timeout():
	casting = false
	allow_cast = false
	cooldown_elapsed = 0
	ghost_timer.stop()
	invoker.accerelation = 40
	invoker.stats.remove_modifier(id)
	invoker.stats.apply_modifiers()
	reset_cooldown()

	invoker.sprite.modulate = Color(1, 1, 1)
	invoker.set_hurt_box_disabled(false)
	invoker.set_body_collision_layer("player")

	if hit_box:
		hit_box.disabled = true

	if 'explosion' in data && data.explosion:
		var explosion_area = data.explosion_area + invoker.stats.spell_area 
		var hit_data = {
			source_id = 'dash_explosion',
			source_node = invoker,
			area = explosion_area,
			base_damage_factor = data.explosion_base_damage_factor,
			damage_knockback = data.damage_knockback,
			damage_type = Global.DAMAGE_TYPE.PHYSICAL,
		}

		var center_position = invoker.collision.position
		var hit_box_area = Global.create_hit_box_area(invoker.global_position, hit_data, "enemy_hurtbox")
		hit_box_area.position = center_position
		invoker.add_child(hit_box_area)

		var floor_hit_effect = Global.create_floor_hit_effect(invoker.global_position, explosion_area, Color('#0fa2ff'))
		floor_hit_effect.position = center_position
		invoker.add_child(floor_hit_effect)

		SFX.add_explosion_short()


func _on_ghost_timer_timeout():
	_create_ghost()


func _on_hit_box_area_entered(area_obj):
	var hit_data = {
		source_id = 'dash_passing_through',
		target_node = area_obj.get_parent(),
		damage_type = Global.DAMAGE_TYPE.PHYSICAL,
		attack_type = Global.ATTACK_TYPE.MELEE,
		base_damage_factor = data.base_damage_factor,
		damage_knockback = 0,
		position = invoker.global_position,
	}
	hit_data = invoker.stats.hit(hit_data)
	area_obj.hitted(hit_data)
	



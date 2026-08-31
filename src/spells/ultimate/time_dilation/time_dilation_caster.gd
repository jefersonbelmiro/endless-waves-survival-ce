extends BaseCaster

var cooldown_elapsed: float = 0
var casting = false
var allow_cast = false

var time_scale = 0.3

onready var duration_timer = $duration_timer


func _input(event: InputEvent) -> void:
	if allow_cast && event.is_action_pressed(icon_node.action_name):
		cast()


func _process(delta: float):
	if !caster.is_alive():
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
	duration_timer.start(get_duration() * time_scale)
	SFX.add_powerup()
	Global.set_time_scale(time_scale, get_duration())

	caster.stats.add_modifier({ id = id, move_speed = 100, attack_speed = 50, cooldown_reduction = 0.2 })
	caster.stats.apply_modifiers()
	Global.add_floor_hit_effect(caster.global_position + Vector2(0, 10), 600, Color("#8e0b99"), 2)


func _on_duration_timer_timeout():
	casting = false
	allow_cast = false
	cooldown_elapsed = 0
	reset_cooldown()
	caster.stats.remove_modifier(id)
	caster.stats.apply_modifiers()

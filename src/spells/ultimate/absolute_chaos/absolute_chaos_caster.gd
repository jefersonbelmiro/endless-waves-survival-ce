extends BaseCaster

var cooldown_elapsed: float = 0
var casting = false
var allow_cast = false

onready var duration_timer = $duration_timer

func _input(event: InputEvent) -> void:
	if allow_cast && event.is_action_pressed(icon_node.action_name):
		cast()


func _process(delta: float):
	if !can_cast():
		return

	cooldown_elapsed += delta

	var cooldown = get_cooldown()
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
	if caster.is_channeling():
		caster.state = caster.STATES.IDLE
	casting = true
	caster.set_ultimate_buff_effect(true)
	caster.stats.add_modifier({ id = id, attack_speed = data.attack_speed, move_speed = data.move_speed, })
	caster.stats.apply_modifiers()
	duration_timer.start(get_duration())
	SFX.add_powerup()


func get_cooldown():
	return data.cooldown - (data.cooldown * caster.stats.cooldown_reduction) 


func _on_duration_timer_timeout():
	casting = false
	allow_cast = false
	cooldown_elapsed = 0
	caster.set_ultimate_buff_effect(false)
	caster.stats.remove_modifier(id)
	caster.stats.apply_modifiers()
	reset_cooldown()

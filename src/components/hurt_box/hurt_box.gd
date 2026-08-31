extends Area2D

export var sprite_path: NodePath
export var damage_text_color = Color('#f79617') 
export var damage_sprite_color = Color('#dc0500')

var sprite
var parent
var stats: Stats

onready var hit_effect_timer = $hit_effect_timer


func _ready():
	parent = get_parent() 
	stats = parent.stats if parent.stats else parent.get_node("stats")
	sprite = get_node(sprite_path)


func damage_effect(damage: float, position: Vector2, critital: bool, sfx: bool):
	if !critital:
		Global.add_damage_text(damage, position, damage_text_color)
	else:
		Global.add_critical_damage_text(damage, position, damage_text_color)
	if sfx:
		SFX.add_hit({ ref_node = parent })
	if is_instance_valid(sprite):
		sprite.material.set_shader_param('add_color', true)
		sprite.material.set_shader_param('color', damage_sprite_color)


func hitted(data):
	if !parent.is_alive():
		return

	var result = stats.hitted(data)
	if result:
		# @FIXME shield dont have state
		if 'state' in parent && stats.current_health > 0 && parent.is_alive():
			parent.state = parent.STATES.HITTED
		var critital = false
		if 'critical' in data && data.critical:
			critital = true
		var sfx = Global.player.is_alive()
		if 'mute_sfx' in data && data.mute_sfx:
			sfx = false
		damage_effect(data.damage, global_position, critital, sfx)
		hit_effect_timer.stop()
		hit_effect_timer.start()
	elif result != null:
		Global.add_miss_text(global_position, damage_text_color)


func _on_hit_effect_timer_timeout():
	# @FIXME shield dont have state
	if 'state' in parent && parent.is_alive():
		if parent != Global.player || !parent.is_channeling():
			parent.state = parent.STATES.IDLE
	sprite.material.set_shader_param('add_color', false)


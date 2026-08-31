extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0

var scene = preload("res://src/spells/autocast/earthshock/earthshock.tscn")


func _process(delta: float):
	if !can_cast():
		return

	var cooldown = get_cooldown()
	if cooldown_elapsed >= cooldown:
		if aspd_ellapsed >= data.cast_time: 
			if _cast():
				_reset()
		aspd_ellapsed += delta
	else:
		cooldown_elapsed += delta
		update_cooldown(cooldown - cooldown_elapsed)


func _reset():
	aspd_ellapsed = 0
	cooldown_elapsed = 0
	reset_cooldown()


func _cast():
	if Global.map.safe_zone:
		return false
	var node = scene.instance()
	node.caster = self
	node.area = data.get_area()
	node.global_position = caster.global_position
	Global.floor_container.call_deferred('add_child', node)
	SFX.add_explosion_4()
	return true



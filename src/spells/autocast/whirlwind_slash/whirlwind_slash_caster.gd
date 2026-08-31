extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var casting := false

var scene = preload("res://src/spells/autocast/whirlwind_slash/whirlwind_slash.tscn")


func _process(delta: float):
	if !can_cast():
		return

	if casting:
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
		casting = false
		return false
	var node = scene.instance()
	node.caster = self
	node.area = data.get_area()
	node.direction = invoker.direction
	node.connect("tree_exiting", self, "_on_attack_finished")
	invoker.add_child(node)
	SFX.add_fast_sword({ size = 10 })
	casting = true
	return true


func _on_attack_finished():
	casting = false

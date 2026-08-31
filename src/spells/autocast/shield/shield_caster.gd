extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var shield_alive = false

var scene = preload("res://src/spells/autocast/shield/shield.tscn")


func _process(delta: float):
	if !can_cast():
		return
	
	if shield_alive:
		return

	var cooldown = get_cooldown()
	if cooldown_elapsed >= cooldown:
		if aspd_ellapsed >= get_attack_speed_time() + data.cast_time: 
			_cast()
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
	var node = scene.instance()
	node.caster = self
	node.connect('deaded', self, '_on_dead')
	caster.add_child(node)
	shield_alive = true

	
func _on_dead():
	shield_alive = false
	

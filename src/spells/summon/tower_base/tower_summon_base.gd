extends KinematicSummonBase
class_name TowerSummonBase

var velocity = Vector2.ZERO
var spawn_ticks = 30
var push_length = 1

func _ready():
	randomize()
	sprite.play()
	sprite.frame = randi() % sprite.frames.get_frame_count('default')
	shadow.play()
	shadow.frame = sprite.frame


func _physics_process(_delta):
	if !Global.map.spawn_bounds_has_point(global_position): 
		var distance = Global.map.get_spawn_center() - global_position
		global_position = Global.player.global_position + distance.normalized() * rand_range(push_length * 0.5, push_length)
		push_length += 1

	velocity = move_and_slide(Vector2.ZERO)
	if get_slide_count():
		velocity = move_and_slide(Vector2(rand_range(1, 8), rand_range(1, 8)))
	spawn_ticks -= 1
	if spawn_ticks <= 0:
		set_physics_process(false)


func die():
	.die()
	var scroll_id = data.uid.replace("spell_", "consumable_") + "_scroll"
	var scroll_data = summoner.stats.modifiers.get(scroll_id)
	scroll_data.current_stack_length -= 1
	if scroll_data.current_stack_length <= 0:
		summoner.stats.remove_modifier(scroll_id) 
		if !summoner.deck.cards.has(data.id):
			summoner.remove_card(data.id)


func _on_stats_health_changed():
	health_bar.max_value = stats.max_health
	# clamp() to prevent empty bar as the damage is float
	health_bar.value = stats.current_health #clamp(stats.current_health, stats.max_health * 0.1, stats.max_health)
	health_bar.show()
	health_bar_hide_timer.stop()
	health_bar_hide_timer.start()


func _on_health_bar_hide_timer_timeout():
	health_bar.hide()


func _on_stats_deaded():
	die()

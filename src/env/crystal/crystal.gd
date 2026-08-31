extends KinematicBody2D

enum STATES { SPAWNING, IDLE, DEAD, HITTED }

var state = STATES.IDLE
var data

onready var sprite = $sprite
onready var shadow = $shadow
onready var stats: Stats = $stats
onready var health_bar = $health_bar
onready var health_bar_hide_timer = $health_bar/health_bar_hide_timer


func _ready():
	sprite.play()
	shadow.play()
	set_process(false)


func is_alive():
	return !(state == STATES.DEAD || state == STATES.SPAWNING)


func die():
	if state == STATES.DEAD:
		return
	state = STATES.DEAD

	# player already defeated
	if !Global.player.is_alive():
		return

	# stop event system
	Global.map.event_system.queue_free()

	# move camera to crystal position
	Global.player.camera.follow_player = false
	Global.player.camera.move_to(global_position, 400)

	# stop player
	Global.player.state = Global.player.STATES.SPAWNING
	Global.player.sprite.play('idle')

	# stop main music
	Global.stop_main_music()

	get_tree().create_timer(0.5, false).connect("timeout", self, "_die_effect")


func _die_effect():
	hide()
	$dead_sfx.play()
	$defeated_sfx.play()
	Global.remove_current_time_scale()
	Engine.time_scale = 0.3
	Global.add_dead_effect(global_position, Color("#4c94da"))
	Global.add_floor_hit_effect(global_position + Vector2(0, 10), 600, Color("#4c94da"))
	get_tree().create_timer(0.5, false).connect("timeout", self, "_set_objective_status")


func _exit_tree():
	Engine.time_scale = 1


func _set_objective_status():
	Engine.time_scale = 1
	Global.emit_signal('objective_status_changed', false)


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

extends Node2D

onready var vertical_particle = $vertical_particle
onready var circle_particle = $circle_particle
onready var glow = $glow
onready var marker_animated = $marker_animated
onready var input_icon = $input_icon

var target
var channeling_timer: Timer
var channeling_delay: float = 1.5
var channeling_time: float = 0
var mode = Global.ACTIVATE_PORTAL_MODES.INSTANTLY
var activated = false
var instaled = false


func _ready():
	if Settings.get_particle_effect():
		vertical_particle.emitting = true
		circle_particle.emitting = true
	if Settings.get_glow_effect():
		glow.show()
	set_process(false)
	set_process_input(false)
	mode = Settings.get_activate_portal()
	if Global.is_mobile() && mode == Global.ACTIVATE_PORTAL_MODES.ACTION:
		mode = Global.ACTIVATE_PORTAL_MODES.INSTANTLY

	Settings.connect("changed", self, "_on_settings_changed")


func _input(event):
	if event.is_action_pressed("ui_action_active"):
		_activate()


func _process(delta):
	if !target:
		return
	
	# cancel
	if target.input_direction:
		_uninstall_mode()
		return

	_process_mode(delta)


func _activate():
	if activated:
		return
	activated = true
	Global.emit_signal('player_portal_endered')
	_uninstall_mode()
	if channeling_timer:
		channeling_timer.stop()


func _install_mode():
	if mode == Global.ACTIVATE_PORTAL_MODES.CHANNELING:
		_install_channeling()
	elif mode == Global.ACTIVATE_PORTAL_MODES.ACTION:
		_install_action()
	else:
		_activate()
	instaled = true


func _process_mode(delta):
	if mode == Global.ACTIVATE_PORTAL_MODES.CHANNELING:
		_process_channeling(delta)


func _uninstall_mode():
	if mode == Global.ACTIVATE_PORTAL_MODES.CHANNELING:
		_uninstall_channeling()
	elif mode == Global.ACTIVATE_PORTAL_MODES.ACTION:
		_uninstall_action()
	instaled = false


func _install_action():
	input_icon.show()
	set_process_input(true)


func _uninstall_action():
	input_icon.hide()
	set_process_input(false)


func _install_channeling():
	set_process(true)
	target.state = target.STATES.CHANNELING
	target.set_hurt_box_disabled(true)
	if !Global.player.is_connected("state_changed", self, "_on_state_changed"):
		Global.player.connect("state_changed", self, "_on_state_changed")

	if !channeling_timer:
		channeling_timer = Timer.new()
		channeling_timer.autostart = true
		channeling_timer.wait_time = 0.2
		channeling_timer.connect("timeout", self, "_on_channeling_timer_timeout")
		add_child(channeling_timer)
	elif !instaled:
		channeling_timer.stop()
		channeling_timer.start()


func _process_channeling(delta):
	target.global_position = target.global_position.linear_interpolate(global_position + Vector2(0, -10), 0.05)
	target.sprite.animation = 'idle'
	target.sprite.frame = 0
	target.sprite.position.y -= 10 * delta


func _uninstall_channeling():
	set_process(false)
	channeling_time = 0
	if target:
		target.sprite.position.y = 0
		target.set_hurt_box_disabled(false)
		if !activated:
			target.state = target.STATES.IDLE
	if channeling_timer && !activated:
		channeling_timer.stop()
		if mode == Global.ACTIVATE_PORTAL_MODES.CHANNELING && channeling_timer.is_inside_tree():
			channeling_timer.start()


func _on_channeling_timer_timeout():
	if mode != Global.ACTIVATE_PORTAL_MODES.CHANNELING:
		return
	channeling_time += 0.2
	if !target:
		channeling_timer.stop()
	elif channeling_time >= channeling_delay:
		_activate()
	elif !instaled:
		_install_mode()


func _on_state_changed(new_state):
	if mode != Global.ACTIVATE_PORTAL_MODES.CHANNELING:
		return
	if new_state != Global.player.STATES.CHANNELING:
		_uninstall_channeling()


func _on_marker_animated_timer_timeout():
	marker_animated.show()
	marker_animated.frame = 0
	marker_animated.play()


func _on_marker_animated_animation_finished():
	marker_animated.hide()


func _on_portal_body_entered(body):
	if is_instance_valid(body) && body.is_alive():
		target = body
		_install_mode()


func _on_portal_body_exited(_body:Node):
	_uninstall_mode()
	if channeling_timer:
		channeling_timer.stop()
	target = null


func _on_settings_changed(key: String):
	if key == 'general.activate_portal':
		if target:
			_uninstall_mode()
		mode = Settings.get_activate_portal()
		if target:
			_install_mode()


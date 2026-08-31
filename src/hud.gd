extends CanvasLayer

onready var upgrade_popup = $upgrade_popup
onready var pause_popup = $pause_popup
onready var summary_popup = $summary_popup
onready var backpack_popup = $backpack_popup
onready var objective_status_popup = $objective_status_popup 
onready var backpack_edit_popup = $backpack_edit_popup 

onready var container = $container
onready var level_label = $container/level
onready var elapsed_label = $container/elapsed_label
onready var elapsed_timer = $container/elapsed_timer
onready var upgrades_label = $container/right_container/upgrades/label
onready var kills_label = $container/right_container/kills/label
onready var coins_label = $container/right_container/coins/label
onready var exp_label = $container/exp_label
onready var health_label = $container/health_label
onready var exp_bar = $container/left_container/exp_bar
onready var health_bar = $container/left_container/health_bar

onready var touch_pause_button = $container/right_container/touch_actions_container/pause
onready var touch_upgrade_button = $container/right_container/touch_actions_container/upgrade
onready var upgrade_points_icon = $container/right_container/upgrades
onready var upgrade_icon = $container/upgrade_icon


func _ready():
	container.hide()
	Global.connect("player_exp_changed", self, "_on_player_exp_changed")
	Global.connect("player_level_changed", self, "_on_player_level_changed")
	Global.connect("player_upgrade_points_changed", self, "_on_player_upgrade_points_changed")
	Global.connect("player_coins_changed", self, "_on_player_coins_changed")
	Global.connect("player_health_changed", self, "_on_player_health_changed")
	Global.connect("player_spawned", self, "_on_player_spawned")
	Global.connect("enemy_died", self, "_on_enemy_died")
	Global.connect("objective_status_changed", self, "_on_objective_status_changed")
	Settings.connect("changed", self, "_on_settings_changed")
	
	if Global.has_touchscreen():
		$container/right_container/touch_actions_container.show()
		container.margin_left = 8
		container.margin_right = -8
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_open_upgrade"):
		_open_upgrade_popup()
	elif event.is_action_pressed("pause"):
		pause_popup.open()
		_set_pause(true)
	elif event.is_action_pressed("ui_open_backpack"):
		_open_backpack_popup()
		

func _notification(what):
	match what:
		# MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		# 	Global.set_paused(true)
		# MainLoop.NOTIFICATION_WM_FOCUS_IN:
		# 	Global.set_paused(false)
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			if pause_popup.visible:
				Global.quit()
			else:
				Global.add_confirm("QUIT_CONFIRM").connect("confirmed", self, "_on_quit_confirmed")


func _on_quit_confirmed():
	Global.quit()


func _on_player_exp_changed():
	exp_label.text = str(int(Global.player.experience)) + '/' + str(int(Global.player.next_level_exp))
	exp_bar.value = Global.player.experience

	
func _on_player_level_changed():
	exp_label.text = str(Global.player.experience) + '/' + str(Global.player.next_level_exp)
	exp_bar.max_value = Global.player.next_level_exp
	exp_bar.value = 0
	upgrades_label.text = str(Global.player.upgrade_points)
	_update_level_label()


func _on_player_upgrade_points_changed():
	upgrades_label.text = str(Global.player.upgrade_points)
	if Global.has_touchscreen() && !Settings.get_auto_levelup():
		touch_upgrade_button.visible = Global.player.upgrade_points > 0 
	elif !Settings.get_auto_levelup():
		# @FIXME
		# wait caster created to check if has activated card
		yield(get_tree().create_timer(0.1, false), 'timeout')
		upgrade_icon.visible = Global.player.upgrade_points > 0  
		_fix_upgrade_icon_position()


func _on_player_health_changed():
	health_bar.max_value = Global.player.stats.max_health
	health_bar.value = Global.player.stats.current_health
	health_label.text = "%d/%d" % [Global.player.stats.current_health, Global.player.stats.max_health]
	

func _on_player_coins_changed(_amount: int):
	_update_coins()
	

func _on_enemy_died(_enemy):
	Global.kills += 1
	kills_label.text = str(Global.kills)
	
	
func _on_player_spawned():
	container.show()
	elapsed_timer.start()

	_on_player_level_changed()
	_on_player_health_changed()
	elapsed_label.text = Formatter.format_ellapsed(Global.time_ellapsed)
	kills_label.text = str(Global.kills)
	upgrade_points_icon.visible = !Settings.get_auto_levelup()


func _on_objective_status_changed(status):
	container.hide()
	var delay = 0.8
	if status == Global.OBJECTIVE_STATUS.LOSE && Global.player.is_dead():
		Global.add_player_dead_effect(Global.player.global_position)
	elif status == Global.OBJECTIVE_STATUS.WIN:
		Global.add_player_victory_effect(Global.player.global_position)
	elif status == Global.OBJECTIVE_STATUS.QUIT:
		delay = 0.5
		Global.add_player_quit_effect(Global.player.global_position)
	else:
		push_error("invalid status: %s" % [status])
	
	get_tree().create_timer(delay, false).connect("timeout", objective_status_popup, 'open', [status])


func _update_level_label():
	level_label.text = '%s %s' % [tr('LEVEL'), Global.player.level]


func _update_coins():
	coins_label.text = str(Global.player.coins)


func _fix_upgrade_icon_position():
	if Global.hud_spell_slots.has_activated():
		upgrade_icon.rect_position = Vector2(460, 212)
		upgrade_icon.margin_left = -20
		upgrade_icon.margin_top = -48
		upgrade_icon.margin_right = -4
		upgrade_icon.margin_bottom = -32
	else:
		upgrade_icon.rect_position = Vector2(460, 220)
		upgrade_icon.margin_left = -20
		upgrade_icon.margin_top = -40
		upgrade_icon.margin_right = -4
		upgrade_icon.margin_bottom = -24
	

func _set_pause(value: bool):
	if value:
		Global.set_paused(value)
		return
	if upgrade_popup.visible || pause_popup.visible || backpack_popup.visible:
		return
	Global.set_paused(false)


func _on_timer_timeout():
	if !Global.player.is_alive():
		return
	Global.time_ellapsed += 1
	elapsed_label.text = Formatter.format_ellapsed(Global.time_ellapsed)


func _on_upgrade_popup_popup_hide():
	upgrades_label.text = str(Global.player.upgrade_points)
	_on_player_health_changed()
	_on_player_level_changed()
	_on_player_exp_changed()
	_update_coins()
	_set_pause(false)


func _on_pause_popup_popup_hide():
	_set_pause(false)


func _on_backpack_popup_hide():
	_set_pause(false)
	

func _on_chest_popup_hide():
	_set_pause(false)


func _on_pause_button_pressed():
	pause_popup.open()
	Global.delay_func(self, "_set_pause", 0.1, { binds = [true], pause_mode_process = true })


func _on_upgrade_button_pressed():
	_open_upgrade_popup()


func _on_backpack_button_pressed():
	_open_backpack_popup()
	
	
func _on_quit_dialog_confirmed():
	get_tree().quit()

	
func _open_upgrade_popup():
	if Global.player.upgrade_points <= 0:
		return
	_set_pause(true)
	upgrade_popup.open()


func _open_backpack_popup():
	if !is_instance_valid(Global.player) || !Global.player.is_alive():
		return
	backpack_popup.open()
	_set_pause(true)
	

func _on_settings_changed(key: String):
	if key == 'general.language':
		_update_level_label()
	if key == 'general.auto_levelup':
		upgrade_points_icon.visible = !Settings.get_auto_levelup()
		upgrade_icon.visible = !Settings.get_auto_levelup() && Global.player.upgrade_points > 0  
		_fix_upgrade_icon_position()


func _on_upgrade_popup_action_pause_pressed():
	if !pause_popup.visible:
		pause_popup.open()



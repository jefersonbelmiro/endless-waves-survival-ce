extends Node

var time_scale
var target_fps = 60
var threshold_fps = 5
var fps_values = []
var viewport_bounds: Rect2
var world_env: WorldEnvironment

onready var map_container = $map_container
onready var music_player = $music_player


func _ready():
	VisualServer.set_default_clear_color(Color('#000'))
	get_tree().set_auto_accept_quit(false)

	Global.connect("player_coins_changed", self, "_on_player_coins_changed")
	Global.connect("player_deaded", self, "_on_player_deaded")
	Global.connect("player_quit", self, "_on_player_quit")
	Global.connect("player_portal_endered", self, "_on_player_portal_endered")
	Global.connect("objectives_completed", self, "_on_objectives_completed")
	Global.connect("game_paused_changed", self, "_on_game_paused_changed")
	Settings.connect("changed", self, "_on_settings_changed")

	# reset global data like logs, time ellapsed and kills
	Global.reset_data()

	# create char player
	Global.player = Global.create_char(Global.session.current_char_id)
	Global.set_nodes_refs()
	Global.add_entity_deferred(Global.player)
	
	# create map
	Global.map = Global.create_map(Global.session.current_map_id)
	map_container.add_child(Global.map)

	# set player start position
	Global.player.global_position = Global.map.get_node('start_position').global_position

	_on_settings_changed('general.glow_effect')

	# create debug console
	if OS.is_debug_build():
		var debug_console_popup_scene = load("res://src/debug/popup/debug_console/debug_console_popup.tscn")
		get_node("hud").add_child(debug_console_popup_scene.instance())

	var performance_check_timer = Timer.new()
	performance_check_timer.wait_time = 1.0
	performance_check_timer.autostart = true
	performance_check_timer.connect("timeout", self, "_on_performance_check_timer_timeout")
	add_child(performance_check_timer)

	if Global.is_plataform_crazygames():
		var crazygames_sdk = Global.load_crazygames_sdk()
		crazygames_sdk.configure_game(self)


func _exit_tree():
	if time_scale:
		_on_set_time_scale_timeout()


func _process(_delta):
	var viewport_size = Global.player.get_viewport_rect().size * Global.player.camera.zoom
	var position = Global.player.camera.get_camera_screen_center() - viewport_size/2.0
	viewport_bounds = Rect2(position, viewport_size)


func set_time_scale(value: float, duration: float):
	time_scale = value
	var pitch_shift_effect := AudioEffectPitchShift.new()
	pitch_shift_effect.pitch_scale = 0.9
	AudioServer.add_bus_effect(AudioServer.get_bus_index("SFX"), pitch_shift_effect, 0)
	Engine.time_scale = value
	get_tree().create_timer(duration * value, false).connect("timeout", self, "_on_set_time_scale_timeout")


func remove_current_time_scale():
	if time_scale:
		Engine.time_scale = 1.0
		if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("SFX")):
			AudioServer.remove_bus_effect(AudioServer.get_bus_index("SFX"), 0)


func _on_set_time_scale_timeout():
	time_scale = null
	Engine.time_scale = 1.0
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("SFX")) > 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("SFX"), 0)


func _on_game_paused_changed(paused):
	if time_scale:
		if paused:
			Engine.time_scale = 1.0
			if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("SFX")):
				AudioServer.remove_bus_effect(AudioServer.get_bus_index("SFX"), 0)
		else:
			var pitch_shift_effect := AudioEffectPitchShift.new()
			pitch_shift_effect.pitch_scale = 0.9
			AudioServer.add_bus_effect(AudioServer.get_bus_index("SFX"), pitch_shift_effect, 0)
			Engine.time_scale = time_scale


func _on_player_coins_changed(amount: int):
	Global.log_data.coins += amount
	

func _on_player_level_changed():
	Global.log_data.player_level = Global.player.level


func _on_player_deaded():
	Global.stop_main_music()
	Global.log_data.player_deaths += 1

	var score = Global.calcule_score()
	var best_score = Global.get_persited_high_score()
	if score > best_score:
		Global.session.map.new_high_score = true

	Global.persist_meta()
	Global.emit_signal('objective_status_changed', Global.OBJECTIVE_STATUS.LOSE)
	

func _on_player_quit():
	Global.stop_main_music()

	var score = Global.calcule_score()
	var best_score = Global.get_persited_high_score()
	if score > best_score:
		Global.session.map.new_high_score = true

	Global.persist_meta()

	if Global.hud.upgrade_popup.visible:
		Global.hud.upgrade_popup.hide()

	if Global.time_ellapsed >= 5 && Global.player.is_alive():
		Global.emit_signal('objective_status_changed', Global.OBJECTIVE_STATUS.QUIT)
	else:
		get_tree().change_scene_to(Global.menu_screen_scene)


func _on_player_portal_endered():
	Global.stop_main_music()

	var map_meta = Persistent.get_map(Global.session.current_map_id)
	Global.session.map.coins_complete_objectives = Global.COINS_BONUS_COMPLETE_OBJECTIVES * map_meta.level 
	if Persistent.map_unlock_next_level(Global.session.current_map_id):
		Global.session.map.coins_unlock_level = Global.COINS_BONUS_UNLOCK_MAP_LEVEL
	Global.player.coins += Global.session.map.coins_complete_objectives + Global.session.map.coins_unlock_level 

	Global.persist_meta()
	Global.emit_signal('objective_status_changed', Global.OBJECTIVE_STATUS.WIN)


func _on_objectives_completed():
	if Global.player.is_alive():
		Global.add_portal()
		Global.add_toast(tr("OBJECTIVES_COMPLETED"))


func _on_performance_check_timer_timeout():
	var current_fps = Engine.get_frames_per_second()
	fps_values.append(current_fps)
	if fps_values.size() > 10:
		fps_values.pop_front()
	var average_fps = FP.average(fps_values)
	if current_fps > target_fps:
		target_fps = current_fps
	if current_fps >= target_fps - threshold_fps && average_fps >= target_fps - threshold_fps:
		return

	for index in Targets.nodes.size():
		var node = Targets.nodes[index]
		if !is_instance_valid(node):
			continue
		if "move_method" in node:
			node.move_method = "move_and_collide"


func _on_settings_changed(key: String):
	if key != 'general.glow_effect':
		return

	var containers = ['floor_container', 'drop_container', 'entity_container']
	if Settings.get_glow_effect():
		if !is_instance_valid(world_env):
			world_env = Global.world_env_scene.instance()
			add_child(world_env)
			for container_key in containers:
				var node = Global.get(container_key)
				node.modulate = Color(1.2, 1.2, 1.2)
	else:
		if is_instance_valid(world_env):
			world_env.queue_free()
		for container_key in containers:
			var node = Global.get(container_key)
			node.modulate = Color(1, 1, 1)



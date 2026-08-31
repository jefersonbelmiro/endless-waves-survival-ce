extends Node

signal changed(category, key)
signal language_changed()

const FILE_NAME = "settings.cfg"
const DB_MUTED = -40

var file_path = "user://%s" % [FILE_NAME]

var _config_file = ConfigFile.new()
var _settings = {
	general = {
		use_new_version = true,
		language = null,
		particle_effect = true,
		glow_effect = false,
		floating_text = true,
		enemy_health_bar = true,
		autocast_icons = true,
		fullscreen = true,
		camera_zoom = null,
		auto_levelup = true,
		activate_portal = null,
		aim_mode = 'auto',
		crosshair = {
			image_index = 39,
			color = '#e8ea18',
			scale = 1.818182,
			outline = true,
			outline_inside = false,
			outline_size = 0.6,
		},
	},
	audio = {
		music_volume = 0,
		sfx_volume = 0,
	},
	controller = {
		device = null,
	},
}


func _ready():
	Settings.set_setting('general', 'use_new_version', true)
	load_settings()

	if !get_language():
		var locales = TranslationServer.get_loaded_locales()
		if locales.has(OS.get_locale()):
			set_language(OS.get_locale())
		elif locales.has(OS.get_locale_language()):
			set_language(OS.get_locale_language())
		else:
			set_language('en')

	if get_camera_zoom() == null:
		set_camera_zoom(0.25 if Global.is_mobile() else 0.0)

	if get_activate_portal() == null:
		set_activate_portal(2 if Global.is_mobile() else 1)

	# set false fullscreen on html 
	if Global.is_html() && get_fullscreen():
		set_fullscreen(false)


func set_language(value):
	return set_setting('general', 'language', value) 


func get_language():
	return get_setting('general', 'language') 
	
	
func set_music_volume(value):
	return set_setting('audio', 'music_volume', value) 


func get_music_volume():
	return get_setting('audio', 'music_volume') 


func has_music_muted():
	return get_music_volume() <= DB_MUTED


func set_sfx_volume(value):
	return set_setting('audio', 'sfx_volume', value) 


func get_sfx_volume():
	return get_setting('audio', 'sfx_volume') 


func has_sfx_muted():
	return get_sfx_volume() <= DB_MUTED


func set_particle_effect(value):
	return set_setting('general', 'particle_effect', value) 


func get_particle_effect():
	return get_setting('general', 'particle_effect') 


func set_glow_effect(value):
	return set_setting('general', 'glow_effect', value) 


func get_glow_effect():
	return get_setting('general', 'glow_effect') 


func set_floating_text(value):
	set_setting('general', 'floating_text', value) 


func get_floating_text():
	return get_setting('general', 'floating_text') 


func set_fullscreen(value):
	set_setting('general', 'fullscreen', value) 


func get_fullscreen():
	return get_setting('general', 'fullscreen') 


func set_camera_zoom(value):
	set_setting('general', 'camera_zoom', value) 


func get_camera_zoom():
	return get_setting('general', 'camera_zoom') 


func set_auto_levelup(value):
	set_setting('general', 'auto_levelup', value) 


func get_auto_levelup():
	return get_setting('general', 'auto_levelup') 


func set_enemy_health_bar(value):
	set_setting('general', 'enemy_health_bar', value) 


func get_enemy_health_bar():
	return get_setting('general', 'enemy_health_bar') 


func set_autocast_icons(value):
	set_setting('general', 'autocast_icons', value) 


func get_autocast_icons():
	return get_setting('general', 'autocast_icons') 


func set_activate_portal(value):
	set_setting('general', 'activate_portal', value) 


func get_activate_portal():
	return get_setting('general', 'activate_portal') 


func set_aim_mode(value):
	return set_setting('general', 'aim_mode', value) 


func get_aim_mode():
	return get_setting('general', 'aim_mode') 


func set_crosshair(value):
	return set_setting('general', 'crosshair', value) 


func get_crosshair():
	return get_setting('general', 'crosshair') 


func set_controller_device(value):
	return set_setting('controller', 'device', value) 


func get_controller_device():
	return get_setting('controller', 'device') 


func save_settings():
	for section in _settings.keys():
		for key in _settings[section].keys():
			_config_file.set_value(section, key, _settings[section][key])
	
	_config_file.save(file_path)


func load_settings():
	_migrate_file()
	var error = _config_file.load(file_path)
	if error != OK:
		return false

	for section in _settings.keys():
		for key in _settings[section].keys():
			if _config_file.has_section_key(section, key):
				var val = _config_file.get_value(section, key)
				_settings[section][key] = val
	return true


func get_setting(category, key, default_value = null):
	if !_settings.has(category) || !_settings[category].has(key) || _settings[category][key] == null:
		return default_value
	return _settings[category][key]


func set_setting(category, key, value):
	var diff = get_setting(category, key) != value
	_settings[category][key] = value
	if diff:
		emit_signal('changed', "%s.%s" % [category, key])
		if key == 'language':
			emit_signal('language_changed')


func _migrate_file():
	if Global.is_plataform_steam():
		_migrate_steam_file()


func _migrate_steam_file():
	var base = "%s/data" % [OS.get_executable_path().get_base_dir()]
	var path = "%s/%s" % [base, FILE_NAME]
	var file = File.new()
	var dir = Directory.new()
	# create data diretory if not exits
	if !dir.dir_exists(base):
		var res = dir.make_dir(base)
		if res != OK:
			return
	# new file exits
	if file.file_exists(path):
		file_path = path
		return 
	# old file exits
	elif file.file_exists(file_path):
		var res = dir.copy(file_path, path)
		if res != OK:
			return
	# migrated or not exits
	file_path = path



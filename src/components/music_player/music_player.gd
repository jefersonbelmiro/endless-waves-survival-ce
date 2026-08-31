extends Node

const tracks = {
	"Adhesive Wombat - 8 Bit Adventure": {
		start_offset = 0,
		loop_offset = 18.82,
		stop_offset = 0, 
		resource = "res://assets/sfx/musics/Adhesive Wombat - 8 Bit Adventure.wav",
	},
	"DubStepDropBoom": {
		start_offset = 0,
		loop_offset = 15.96,
		stop_offset = 0, 
		resource = "res://assets/sfx/musics/playlist/DubStepDropBoom.wav",
	},
	"sergii_-_Tale_Spin_Boss_Fight_theme(T-Sergii_mix)": {
		start_offset = 0,
		loop_offset = 16.992,
		stop_offset = 0,
		resource = "res://assets/sfx/musics/playlist/sergii_-_Tale_Spin_Boss_Fight_theme(T-Sergii_mix).wav",
	},
	"ninsid_-_Blow_up!_Green_Screen": {
		start_offset = 0,
		loop_offset = 15.56,
		stop_offset = 0, 
		resource = "res://assets/sfx/musics/playlist/ninsid_-_Blow_up!_Green_Screen.wav",
	},
	"DynamicFight_1": {
		start_offset = 0,
		loop_offset = 19.9,
		stop_offset = 0,
		resource = "res://assets/sfx/musics/playlist/DynamicFight_1.wav",
	},
	"DynamicFight_2": {
		start_offset = 0,
		loop_offset = 14.08,
		stop_offset = 0,
		resource = "res://assets/sfx/musics/playlist/DynamicFight_2.wav",
	},
	"DynamicFight_3": {
		start_offset = 0,
		stop_offset = 0,
		loop_offset = 0,
		resource =  "res://assets/sfx/musics/playlist/DynamicFight_3.wav",
	},
	"Gumbel - Levels": {
		start_offset = 0,
		loop_offset = 22.0,
		stop_offset = 0,
		resource = "res://assets/sfx/musics/playlist/Gumbel - Levels.wav",
	},
	"Underclocked (underunderclocked mix)": {
		start_offset = 0,
		loop_offset = 26.53,
		stop_offset = 0,
		resource = "res://assets/sfx/musics/playlist/Underclocked (underunderclocked mix).wav"
	}
}

const MODES = { RAMDOM = 'ramdom', TRACK = 'track' }

var mode = MODES.RAMDOM
var tracks_keys = tracks.keys()
var previous_track
var current_track
var playing = false
var track_name: String

var switch_duration = 5.0
var track_index: int
var loading = true
var music_muted = false
var async_loader

func _ready():
	music_muted = Settings.has_music_muted()

	Settings.connect("changed", self, "_on_settings_changed")

	if Global.is_html():
		mode = MODES.TRACK
		tracks_keys = [tracks_keys[0]]
		track_name = tracks_keys[0]
	
	async_loader = Global.get_async_loader()
	for key in tracks_keys:
		var track = tracks[key]
		async_loader.add_queue(track.resource)
	async_loader.connect("queue_completed", self, "_on_resource_loaded")
	async_loader.start()


func start():
	if playing || loading:
		return
	playing = true
	if mode == MODES.RAMDOM:
		tracks_keys.shuffle()
		track_index = randi() % tracks_keys.size()
		_play_next(true)
	elif mode == MODES.TRACK:
		track_index = tracks_keys.find(track_name)
		current_track = tracks[tracks_keys[track_index]].duplicate()
		_create_player()
		_play(true)


func stop():
	if !playing:
		return
	playing = false
	_stop_track(previous_track)
	_stop_track(current_track)


func resume():
	if playing || music_muted:
		return
	playing = true
	_resume_track(previous_track)
	_resume_track(current_track)


func _play_next(from_start = false):
	previous_track = current_track
	track_index = (track_index + 1) % tracks_keys.size()
	current_track = tracks[tracks_keys[track_index]].duplicate()

	_create_player()
	_play(from_start)


func _play(from_start = false):
	current_track.player.name = "track_%s" % [track_index]

	if from_start:
		current_track.player.play(current_track.start_offset)
	else:
		current_track.player.play(current_track.loop_offset)

	_create_switch_tween()
	_create_timer()


func _repeat():
	current_track.timer.start()
	current_track.player.play(current_track.loop_offset)


func _create_switch_tween():
	if _is_valid(previous_track, 'player') && previous_track.player.playing:
		previous_track.tween = create_tween()
		previous_track.tween.tween_property(previous_track.player, 'volume_db', -40, switch_duration)
		previous_track.tween.connect("finished", self, "_on_phade_tween_finished", [previous_track])

		current_track.player.volume_db = -40
		current_track.tween = create_tween()
		current_track.tween.tween_property(current_track.player, 'volume_db', -20, switch_duration)


func _create_timer():
	var timeout = current_track.stop_offset
	if !timeout:
		timeout = current_track.player.stream.get_length()

	current_track.timer =  Global.create_timer({
		wait_time = timeout - current_track.player.get_playback_position() - switch_duration - 1,
		autostart = true,
		one_shot = true,
		pause_mode = PAUSE_MODE_PROCESS,
		parent = self,
		on_timeout = { ref = [self, '_on_track_timeout'], binds = [current_track] },
	})


func _create_player():
	var node = AudioStreamPlayer.new()
	node.volume_db = -20
	node.bus = "Music"
	node.stream = current_track.stream
	node.connect("finished", self, "_on_player_finished", [current_track])
	current_track.player = node
	add_child(node)
	return node


func _is_valid(target, key_path: String):
	return is_instance_valid(FP.safe_get(target, key_path))


func _stop_track(track):
	if !track:
		return
	if _is_valid(track, 'timer'):
		track.timer.set_paused(true)
	if _is_valid(track, 'player'):
		track.player.stop()
	if _is_valid(track, 'tween') && track.tween.is_running():
		track.tween.stop()


func _resume_track(track):
	if !track:
		return
	if _is_valid(track, 'timer'):
		track.timer.set_paused(false)
	if _is_valid(track, 'player'):
		track.player.play(track.player.get_playback_position())
	if _is_valid(track, 'tween') && track.tween.is_valid():
		track.tween.play()


func _on_resource_loaded():
	for key in tracks_keys:
		var track = tracks[key]
		track.stream = async_loader.get_resource(track.resource)
	loading = false
	if !Settings.has_music_muted():
		start()


func _on_settings_changed(key: String):
	if key != 'audio.music_volume':
		return
	if music_muted == Settings.has_music_muted():
		return
	music_muted = Settings.has_music_muted()
	Global.debounce_func(self, "_on_music_mute_changed")


func _on_music_mute_changed():
	if music_muted:
		stop()
	elif _is_valid(current_track, 'player'):
		resume()
	elif !_is_valid(current_track, 'player'):
		start()


func _on_phade_tween_finished(track):
	if _is_valid(track, 'player'):
		track.player.queue_free()
	if _is_valid(track, 'timer'):
		track.timer.queue_free()


func _on_player_finished(track):
	# ignore event emitted by stop
	if !playing:
		return
	# timeout is already handling swap
	if _is_valid(track, 'player') && track.player.volume_db != -20:
		return
	# just happen if timeout is not seated correct ¯\_(ツ)_/¯
	if mode == MODES.RAMDOM: 
		if _is_valid(track, 'player'):
			track.player.queue_free()
		if _is_valid(track, 'timer'):
			track.timer.queue_free()
		_play_next()
	elif mode == MODES.TRACK:
		_repeat()


func _on_track_timeout(track):
	if mode == MODES.RAMDOM: 
		if _is_valid(track, 'timer'):
			track.timer.queue_free()
		_play_next()
	elif mode == MODES.TRACK:
		_repeat()

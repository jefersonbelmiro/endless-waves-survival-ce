extends Node

var coin_sfx = preload("res://assets/sfx/effects/sfx_coin_double1.wav")
var experience_sfx = preload("res://assets/sfx/effects/sfx_experience.wav")
var hit_sfx = preload("res://assets/sfx/effects/sfx_damage_hit1.wav")
var healing_sfx = preload("res://assets/sfx/effects/consumable/sfx_healing.wav")
var powerup_sfx = preload("res://assets/sfx/effects/consumable/sfx_powerup.wav")
var button_focus_sfx = preload("res://assets/sfx/effects/button/sfx_button_focus.wav")
var button_pressed_sfx = preload("res://assets/sfx/effects/button/sfx_button_pressed.wav")
var button_error_sfx = preload("res://assets/sfx/effects/button/sfx_button_error.wav")
var ultimate_on_sfx = preload("res://assets/sfx/effects/ultimate_on.wav")
var explosion_short_sfx = preload("res://assets/sfx/effects/sfx_exp_short.wav")
var explosion_short_soft_sfx = preload("res://assets/sfx/effects/sfx_explosion_short_soft.wav")
var explosion_3_sfx = preload("res://assets/sfx/effects/sfx_explosion_3.wav")
var explosion_4_sfx = preload("res://assets/sfx/effects/sfx_explosion_4.wav")
var spell_throw_sfx = preload("res://assets/sfx/effects/sfx_spell_throw.wav")
var throw_sfx = preload("res://assets/sfx/effects/sfx_throw.wav")
var launch_sfx = preload("res://assets/sfx/effects/sfx_launch.wav")
var jump_sfx = preload("res://assets/sfx/effects/sfx_jump.wav")
var fast_sword_sfx = preload("res://assets/sfx/effects/sfx_fast_sword.wav")
var popup_sfx = preload("res://assets/sfx/effects/sfx_popup.wav")
var shield_spell_sfx = preload("res://assets/sfx/effects/sfx_shield_spell.wav")
var teleport_start_sfx = preload("res://assets/sfx/effects/sfx_teleport_start.wav")
var teleport_end_sfx = preload("res://assets/sfx/effects/sfx_teleport_end.wav")
var dash_sfx = preload("res://assets/sfx/effects/sfx_dash.wav")
var chicken_call_sfx = preload("res://assets/sfx/effects/sfx_chicken_call.wav")

var sound_effect_scene = preload("res://src/effects/sound_effect/sound_effect.tscn")
var queue = []
var queue_once = {}
var queue_size = {}

func _ready():
	randomize()
	set_pause_mode(PAUSE_MODE_PROCESS)


func _process(_delta):
	if queue.size() == 0:
		return

	for data in queue:
		var stream
		if 'stream' in data:
			stream = data.stream
		elif 'id' in data:
			var stream_key = data.id + '_sfx'
			if stream_key in self:
				stream = self[stream_key]
		if !stream:
			push_error("invalid queue data: empty stream")
			continue
		if data.once || data.one:
			if data.one && queue_once.has(data.id):
				queue_once[data.id].play(0)
			elif data.once && queue_once.has(data.id):
				continue
			else:
				queue_once[data.id] = _create_instance(stream, data) 
		elif data.size > 0:
			if !queue_size.has(data.id):
				queue_size[data.id] = 0
			if queue_size[data.id] >= data.size:
				continue
			else:
				queue_size[data.id] += 1
				_create_instance(stream, data)
		else:
			_create_instance(stream, data)

	queue.clear()


func add(data):
	_add_queue(data)


func add_coin():
	_add_queue({ id = 'coin', size = 3 })


func add_experience():
	_add_queue({ id = 'experience', size = 3 })


func add_hit(options = null):
	var data = { id = 'hit', random_pitch = true, size = 3, }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_explosion_short(options = null):
	var data = { id = 'explosion_short', random_pitch = true, size = 3 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_explosion_short_soft(options = null):
	var data = { id = 'explosion_short_soft', random_pitch = true, size = 3 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_explosion_3(options = null):
	var data = { id = 'explosion_3', size = 3 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_explosion_4(options = null):
	var data = { id = 'explosion_4', size = 3, volume = 7 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_spell_throw(options = null):
	var data = { id = 'spell_throw', size = 3, volume = -10 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_throw(options = null):
	var data = { id = 'throw', size = 3, volume = -10 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_launch(options = null):
	var data = { id = 'launch', size = 3, volume = -10 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_jump(options = null):
	var data = { id = 'jump', size = 2, volume = -10 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_fast_sword(options = null):
	var data = { id = 'fast_sword', size = 2 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_shield_spell(options = null):
	var data = { id = 'shield_spell', size = 2 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_popup():
	_add_queue({ id = 'popup' })


func add_button_focus():
	var node = sound_effect_scene.instance()
	node.stream = button_focus_sfx
	node.pitch_scale = rand_range(0.7, 1)
	add_child(node)


func add_button_pressed():
	var node = sound_effect_scene.instance()
	node.stream = button_pressed_sfx
	add_child(node)


func add_button_error():
	var node = sound_effect_scene.instance()
	node.stream = button_error_sfx
	node.volume_db += -10
	add_child(node)


func add_ultimate_on():
	var node = sound_effect_scene.instance()
	node.stream = ultimate_on_sfx
	node.pitch_scale = rand_range(0.7, 1)
	add_child(node)


func add_powerup():
	_add_queue({ id = 'powerup', one = true, random_pitch = true })


func add_healing(options = null):
	var data = { id = 'healing', size = 3, random_pitch = true }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_teleport_start(options = null):
	var data = { id = 'teleport_start', size = 3, pitch = 1.5, volume = -10 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_teleport_end(options = null):
	var data = { id = 'teleport_end', size = 3, pitch = 1.5, volume = -10  }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_consumable(consumable_id: String):
	if consumable_id == 'consumable_potion_of_healing':
		add_healing()
	else:
		_add_queue({ id = 'powerup', one = true, random_pitch = true })


func add_dash(options = null):
	var data = { id = 'dash', size = 3, volume = 5 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func add_chicken_call(options = null):
	var data = { id = 'chicken_call', size = 3, volume = 10 }
	if options: data = FP.patch_dictionary(data, options)
	_add_queue(data)


func _create_instance(stream, data):
	var instance = sound_effect_scene.instance()
	instance.stream = stream
	if data.random_pitch:
		instance.pitch_scale = rand_range(0.7, 1)
	elif data.pitch:
		instance.pitch_scale = data.pitch
	if data.once || data.one || data.size > 0: 
		instance.connect("finished", self, "_on_sound_finished", [data.id])
	if 'volume' in data:
		instance.volume_db += data.volume
	queue_once[data.id] = instance
	add_child(instance)
	return instance


func _on_sound_finished(id: String):
	queue_once.erase(id)
	if queue_size.has(id):
		queue_size[id] -= 1
		if queue_size[id] <= 0:
			queue_size.erase(id)


func _add_queue(data):
	var queue_data = {
		id = data.id,
		once = data.once if 'once' in data else false,
		one = data.one if 'one' in data else false,
		size = data.size if 'size' in data else 0,
		random_pitch = data.random_pitch if 'random_pitch' in data else false,
		pitch = data.pitch if 'pitch' in data else 0,
	}
	if 'volume' in data:
		queue_data.volume = data.volume
	if 'stream' in data:
		queue_data.stream = data.stream

	if 'ref_node' in data && data.ref_node && !Global.node_in_viewport(data.ref_node):
		return
	queue.append(queue_data)


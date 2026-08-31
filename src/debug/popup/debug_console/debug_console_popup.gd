extends Popup

onready var output = $container/output
onready var input = $container/input

const command_handler_scene = preload("res://src/debug/popup/debug_console/command_handler/console_command_handler.tscn")
const screenshot_system_scene = preload("res://src/systems/screenshot/screenshot_system.tscn")

var history = { values = [], cursor = -1 }
var game_paused_on_open = false
var command_handlers = {}
var commands = {
	help = {
		label = "Show help info",
		handler = '_command_help',
	},
	die = {
		label = "kill player",
		handler = '_command_die()'
	},
	upgrade_all = {
		label = "Upgrade all",
		handler = '_command_upgrade_all()'
	},
	imortal = {
		label = "Player became imortal",
		handler = '_command_imortal()'
	},
	set_output_font_size = {
		label = "Set output font size",
		handler = '_command_set_output_font_size(value)',
	},
	set_upgrade_points = {
		label = "Set upgrade points",
		handler = '_command_set_upgrade_points(value)',
	},
	set_coins = {
		label = "Set coins",
		handler = '_command_set_coins(value)',
	},
	set_camera_zoom = {
		label = "Set camera zoom",
		handler = '_command_set_camera_zoom(value)',
	},
	show_attack_range = {
		label = "Show player attack_range",
		draw_handler = '_draw_handler_show_attack_range'
	},
	show_cast_area_range = {
		label = "Show cast area range",
		draw_handler = '_draw_handler_show_cast_area_range'
	},
	show_map_bounds = {
		label = "Show map bounds",
		draw_handler = '_draw_handler_show_map_bounds'
	},
	show_map_spawn_bounds = {
		label = "Show map spawn bounds",
		draw_handler = '_draw_handler_show_map_spawn_bounds'
	},
	show_viewport_bounds = {
		label = "Show viewport bounds",
		draw_handler = '_draw_handler_show_viewport_bounds'
	},
	show_map_events = {
		label = "Show map events",
		handler = '_command_show_map_events()'
	},
	show_map_drops = {
		label = "Show map drops",
		handler = '_command_show_map_drops()'
	},
	toggle_screenshot_system = {
		label = "Toggle screenshot system",
		toggle_handler = '_command_toggle_screenshot_system',
		oneshot = true,
	},
}

func _ready():
	randomize()
	
	for key in commands:
		var data = commands[key]
		if 'handler' in data:
			data.handler = _extract_handler(data.handler)
		if 'process_handler' in data:
			data.process_handler = _extract_handler(data.process_handler)
		if 'toggle_handler' in data:
			data.toggle_handler = _extract_handler(data.toggle_handler)
		if 'draw_handler' in data:
			data.draw_handler = _extract_handler(data.draw_handler)


func _input(event):
	if !visible && Input.is_key_pressed(KEY_BACKSLASH):
		get_tree().set_input_as_handled()
		open()
		
	if !visible:
		return
		
	if input.has_focus():
		if event is InputEventKey and event.is_pressed():
			if event.control && event.scancode == KEY_L:
				get_tree().set_input_as_handled()
				_clear_output()
			elif event.scancode == KEY_ENTER:
				get_tree().set_input_as_handled()
				_process_input()
			elif event.scancode == KEY_UP:
				get_tree().set_input_as_handled()
				_move_history(1)
			elif event.scancode == KEY_DOWN:
				get_tree().set_input_as_handled()
				_move_history(-1)


func open():
	if visible:
	   return
	game_paused_on_open = get_tree().paused
	Global.set_paused(true)
	set_process(true)
	Global.opened_popups_add(self)
	popup()
	input.text = ''
	input.focus_mode = FOCUS_ALL
	input.grab_focus()


func _process_input():
	var args = Array(input.text.split(" "))
	var command = args.pop_front()
	if !command:
		return
	history.cursor = -1
	history.values.append(input.text)
	if commands.has(command):
		output.bbcode_text += _execute_command(command, args) + "\n"
	else:
		output.bbcode_text += "[color=red]Error:[/color] invalid command: %s\n" % [input.text]
	input.text = ''


func _execute_command(command: String, args):
	var command_data = commands[command]
	if 'handler' in command_data:
		# missing args
		if command_data.handler.args.size() > args.size():
			var missing_args = Array(command_data.handler.args).slice(
				args.size() - 1 if args.size() else 0, 
				command_data.handler.args.size()
			)
			return '[color=red]Error:[/color] command %s missing args: %s' % [command, PoolStringArray(missing_args).join(', ')]

		# truncate uneccessary args
		elif args.size() > command_data.handler.args.size():
			if command_data.handler.args.size() == 0:
				args = []
			else:
				args = args.slice(0, command_data.handler.args.size() - 1)

		var result = command_data.handler.ref.call_funcv(args)
		if typeof(result) == TYPE_STRING:
			return result
		return '%s %s' % [command, PoolStringArray(args).join(' ')]
		
	if _toggle_command(command_data, args):
		return "%s [color=green]%s[/color]" % [command, "ON"]
	return "%s [color=red]%s[/color]" % [command, 'OFF']


func _toggle_command(command_data, args):
	if command_handlers.has(command_data):
		if command_handlers[command_data] is Node:
			command_handlers[command_data].queue_free()
		else:
			command_data.toggle_handler.ref.call_funcv(args)
		command_handlers.erase(command_data)
		return false
	elif 'toggle_handler' in command_data:
		command_data.toggle_handler.ref.call_funcv(args)
		command_handlers[command_data] = true
		return true
	else:
		var node = command_handler_scene.instance()
		node.args = args
		if 'process_handler' in command_data:
			node.process_handler = command_data.process_handler.ref
		if 'draw_handler' in command_data:
			node.draw_handler = command_data.draw_handler.ref
		Global.game.add_child(node)
		command_handlers[command_data] = node
		return true
		

func _extract_handler(handler_method: String) -> Dictionary:
	var method = Array(handler_method.split('(')).pop_front()
	var args = []
	var regex = RegEx.new()
	regex.compile('\\((.*)\\)')
	var result = regex.search(handler_method)
	if result:
		var args_names = result.get_string(1).replacen(' ', '')
		if args_names:
			args = args_names.split(',')
	return {
		ref = funcref(self, method),
		args = args
	}


func _command_help():
	var lines = []
	for key in commands.keys():
		var label = commands[key].label
		lines.append("[color=green]%s[/color]: %s" % [key, label])
	return PoolStringArray(lines).join("\n")


func _command_die():
	get_tree().create_timer(1, false).connect('timeout', Global.player, 'die')


func _command_imortal():
	Global.player.stats.set_raw_value('max_health', 99999)
	Global.player.stats.set_raw_value('health_regen', 9999)
	Global.player.stats.current_health = 99999
	Global.player.stats.emit_signal("health_changed")
	

func _command_upgrade_all():
	var deck = Persistent.get_deck(Global.session.current_deck_id)
	var all = []
	for card_id in deck.cards.keys():
		all.append(Entities.create_spell_data(card_id)) 
	all.shuffle()
	var has_upgrades = all.size() > 0
	var levels = 0
	while has_upgrades:
		has_upgrades = false
		for index  in all.size():
			var data = all[index]
			var spell_id = data.id
			if Global.player.spells.has(spell_id):
				data = Global.player.spells[spell_id].get_data() 
				if !data.has_upgrade():
					continue
			elif data.cast_type != Global.SKILL_CAST_TYPE.PASSIVE && !Global.hud_spell_slots.can_add(data):
				continue
			has_upgrades = true

			if data.level > 0:
				data.set_next_upgrades(data.get_avaliable_upgrades())

			levels += 1
			Global.player.add_spell(data.id)
			# wait caster be created
			yield(get_tree(), 'idle_frame')
	Global.player.level += levels
	Global.emit_signal('player_level_changed')


func _command_show_map_events():
	var events = Global.map.event_system._current_events
	return JSON.print(events, "\t")


func _command_show_map_drops():
	var events = Global.map.event_system._current_events
	var data = {}
	for event in events:
		for spawn in event.data.spawns:
			if !'drops' in spawn.data:
				continue
			if !data.has(spawn.id):
				data[spawn.id] = {}
			data[spawn.id] = spawn.data.drops
	return JSON.print(data, "\t")


func _command_set_output_font_size(value):
	output.set('custom_fonts/normal_font', Global.get_font(int(value))) 


func _command_set_upgrade_points(value):
	Global.player.upgrade_points = int(value)
	Global.emit_signal('player_upgrade_points_changed')


func _command_set_coins(value):
	Global.player.coins = int(value)
	Global.emit_signal('player_coins_changed', Global.player.coins)


func _command_set_camera_zoom(value):
	Global.player.camera.zoom = Vector2(value, value)


func _command_toggle_screenshot_system():
	var node = get_node_or_null("screenshot_system")
	if node:
		node.queue_free()
		return false
	add_child(screenshot_system_scene.instance())
	return true


func _draw_handler_show_attack_range(node: Node2D):
	var position = node.to_local(Global.player.global_position)
	node.draw_circle(position, Global.player.stats.attack_range, Color('#2d519e50'))


func _draw_handler_show_cast_area_range(node: Node2D):
	# var card_id = node.args[0]
	var caster = Global.player.get_spell("abyssal_sword")

	node.draw_circle(
		node.to_local(Global.player.global_position), 
		caster.area_range / 2.0,
		Color(0, 0.2, 0, 0.4)
	)

	var position = node.to_local(caster.hit_box_position)
	node.draw_circle(position, caster.data.get_area() / 2.0, Color(0.2, 0, 0, 0.4))

	var font = Global.get_font(8)
	node.draw_string(
		font, 
		node.to_local(Global.player.global_position), 
		"target: %s | in_range:%s" % [is_instance_valid(caster.target), caster._target_in_area_range()],
		Color.white
	)


func _draw_handler_show_map_bounds(node: Node2D):
	var position = node.to_local(Global.map.get_bounds().position)
	var end = node.to_local(Global.map.get_bounds().end)
	
	var top_left = position
	var top_right = Vector2(end.x, position.y)
	var bottom_left = Vector2(position.x, end.y)
	var bottom_right = end
	
	var color = Color(1, 0, 0)
	var width = 3
	node.draw_line(top_left, top_right, color, width)
	node.draw_line(top_right, bottom_right, color, width)
	node.draw_line(bottom_right, bottom_left, color, width)
	node.draw_line(bottom_left, top_left, color, width)


func _draw_handler_show_map_spawn_bounds(node: Node2D):
	var position = node.to_local(Global.map.get_spawn_bounds().position)
	var end = node.to_local(Global.map.get_spawn_bounds().end)
	
	var top_left = position
	var top_right = Vector2(end.x, position.y)
	var bottom_left = Vector2(position.x, end.y)
	var bottom_right = end
	
	var color = Color(1, 0, 0)
	var width = 3
	node.draw_line(top_left, top_right, color, width)
	node.draw_line(top_right, bottom_right, color, width)
	node.draw_line(bottom_right, bottom_left, color, width)
	node.draw_line(bottom_left, top_left, color, width)


func _draw_handler_show_viewport_bounds(node: Node2D):
	var position = node.to_local(Global.get_viewport_bounds().position)
	var end = node.to_local(Global.get_viewport_bounds().end)
	
	var top_left = position
	var top_right = Vector2(end.x, position.y)
	var bottom_left = Vector2(position.x, end.y)
	var bottom_right = end
	
	var color = Color(1, 0, 0)
	var width = 3
	node.draw_line(top_left, top_right, color, width)
	node.draw_line(top_right, bottom_right, color, width)
	node.draw_line(bottom_right, bottom_left, color, width)
	node.draw_line(bottom_left, top_left, color, width)


func _clear_output():
	output.bbcode_text = ''


func _move_history(direction: int):
	if history.values.size() == 0:
		return
	if direction > 0:
		history.cursor += 1
		if history.cursor + 1 > history.values.size():
			history.cursor = 0
	else:
		history.cursor -= 1
		if history.cursor < 0:
			history.cursor = history.values.size() - 1

	input.text = history.values[history.values.size() - 1 - history.cursor]
	input.cursor_set_column(input.text.length())


func _on_debug_options_popup_popup_hide():
	input.text = ''
	input.release_focus()
	if !game_paused_on_open:
		Global.set_paused(false)
	Global.opened_popups_remove(self)



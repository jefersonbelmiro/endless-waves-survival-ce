extends Node

signal completed()

export var objectives = []

var completed = 0
var all_completed = false
var kill_enemies_data = {}
var objective_datas = []
var timer_container: Node

func _ready():
	Settings.connect("language_changed", self, "_on_language_changed")
	Global.connect("player_spawned", self, "start")
	timer_container = Node.new() 
	add_child(timer_container)


func start():
	reset()
	for objective in objectives:

		var objective_data = objective.duplicate(true)
		objective_data.completed = false

		if objective.type == 'kill_enemies':
			objective_data.current = 0
			if !'id' in objective:
				kill_enemies_data.all = objective_data
			else:
				objective_data.id_label = objective_data.id.replace('_', ' ').capitalize()
				kill_enemies_data[objective.id] = objective_data
			if !Global.is_connected("enemy_died", self, "_on_enemy_died"):
				Global.connect("enemy_died", self, "_on_enemy_died")

		elif objective.type == 'survive_time':
			var timer_node = Timer.new()
			timer_node.autostart = true
			timer_node.one_shot = true
			timer_node.wait_time = Formatter.format_timer_seconds(objective_data.value)
			timer_node.connect("timeout", self, "_on_survive_timer_timeout", [objective_data])
			timer_container.add_child(timer_node)

		objective_datas.append(objective_data)
		_create_hud_node(objective_data) 
		_update_objective_text(objective_data)

	if objectives.size():
		Global.hud_objectives_container.get_parent().show()
	

# stop watch signals like 'enemy_died'and 'timeout' 
func stop():
	Global.node_remove_children(timer_container)
	if Global.is_connected("enemy_died", self, "_on_enemy_died"):
		Global.disconnect("enemy_died", self, "_on_enemy_died")


# reset all internal variable to start again safely
# remove created HUD nodes
func reset():
	completed = 0
	all_completed = false
	kill_enemies_data = {}
	objective_datas = []
	Global.node_remove_children(timer_container)
	Global.node_remove_children(Global.hud_objectives_container)


func _create_hud_node(objective_data):
	var node = RichTextLabel.new()
	node.bbcode_enabled = true
	node.scroll_active = false
	node.fit_content_height = true
	node.rect_min_size = Vector2(200, 16)
	node.size_flags_horizontal = node.SIZE_EXPAND_FILL
	objective_data.hud_node = node
	Global.hud_objectives_container.add_child(node)


func _update_objective_text(objective_data):
	var node = objective_data.hud_node
	var text = Global.map.get_data().format_objective_values(objective_data) 
	if objective_data.completed:
		node.bbcode_text = "[color=green]%s[/color]" % text
	else:
		node.bbcode_text = "[color=grey]%s[/color]" % text


func _update(objective_data):
	if !all_completed && completed >= objectives.size():
		all_completed = true
		call_deferred("emit_signal", "completed")
	_update_objective_text(objective_data)


func _on_enemy_died(enemy):
	if all_completed:
		return
	if 'all' in kill_enemies_data && !kill_enemies_data.all.completed:
		kill_enemies_data.all.current += 1
		if kill_enemies_data.all.current >= kill_enemies_data.all.value:
			kill_enemies_data.all.completed = true
			completed += 1
		_update(kill_enemies_data.all)
	if enemy.id in kill_enemies_data && !kill_enemies_data[enemy.id].completed:
		kill_enemies_data[enemy.id].current += 1
		if kill_enemies_data[enemy.id].current >= kill_enemies_data[enemy.id].value:
			kill_enemies_data[enemy.id].completed = true
			completed += 1
		_update(kill_enemies_data[enemy.id])


func _on_survive_timer_timeout(objective_data):
	objective_data.completed = true
	completed += 1
	_update(objective_data)


func _on_language_changed():
	for index in objective_datas.size():
		_update(objective_datas[index])


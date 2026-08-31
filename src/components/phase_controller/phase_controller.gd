extends Node

##[codeblock]
##phase = {
##  health: float 
##  handler: string
##  timeout: Int | String
##}
##[/codeblock]
var phases = []
var phase_index = 0
var phase_timeout
var host: Node


func _ready():
	if !is_instance_valid(host):
		return
	_next_phase()


func _on_health_changed():
	if phase_index > phases.size() - 1:
		host.stats.disconnect("health_changed", self, "_on_health_changed")
		return
	var current = phases[phase_index]
	var health_percentage = host.stats.current_health/host.stats.max_health  
	if health_percentage <= current.health:
		_next_phase()


func _next_phase():
	if phase_index > phases.size() - 1:
		return
	var current = phases[phase_index]

	var health_changed_connected = host.stats.is_connected("health_changed", self, "_on_health_changed") 
	if 'health' in current && !health_changed_connected:
		host.stats.connect("health_changed", self, "_on_health_changed")
	elif !'health' in current && health_changed_connected:
		host.stats.disconnect("health_changed", self, "_on_health_changed")

	host.call(current.handler)
	phase_index += 1

	var current_timeout = current.timeout if 'timeout' in current else phase_timeout
	if current_timeout:
		_create_timer(current_timeout, "_next_phase")


func _create_timer(wait_time, handler: String):
	var node = Timer.new()
	node.autostart = true
	node.one_shot = true
	node.wait_time = Formatter.format_timer_seconds(wait_time)
	node.connect("timeout", self, "_on_timer_timeout", [node, handler])
	add_child(node)


func _on_timer_timeout(timer_node, handler):
	call(handler)
	timer_node.queue_free()


extends Node2D

signal timeout

var collisions = []
var dps_delay := 0.5
var dps_elapsed := 0.0

var caster
var get_aim_direction: FuncRef
var direction: Vector2
var use_lerp := false

var spell_data


onready var bg = $anchor/bg
onready var fg = $anchor/fg
onready var collision_area_body = $collision_anchor/area_2d/body
onready var collision_area_head = $collision_anchor/area_2d/head
onready var timeout_timer = $timeout_timer


func _ready():
	spell_data = caster.get_data()

	bg.emitting = true
	fg.emitting = true
	
	bg.process_material.gravity.x = caster.get_area() 

	var distance_width = (bg.process_material.initial_velocity + bg.process_material.gravity.x - bg.process_material.damping * 2) * 2

	collision_area_body.shape.extents.x = distance_width / 2.0 - 46.0
	collision_area_body.position.x = distance_width / 2.0 - 46.0

	collision_area_head.position.x = distance_width - 46.0
	rotation = get_aim_direction.call_func().angle()

	Global.delay_func(self, "_start", 0.5)
	


func _start():
	collision_area_body.disabled = false
	collision_area_head.disabled = false
	timeout_timer.wait_time = caster.get_duration()
	timeout_timer.start()

	
func _physics_process(delta: float):
	var aim_direction  = get_aim_direction.call_func()
	if aim_direction:
		direction = aim_direction
		if use_lerp:
			rotation = lerp_angle(rotation, direction.angle(), 0.3)
		else:
			rotation = direction.angle()

	dps_elapsed += delta
	if dps_elapsed > dps_delay:
		dps_elapsed = 0.0

		for index in collisions.size():
			var node = collisions[index]
			if is_instance_valid(node):
				_apply_dps(node)

	
func _apply_dps(area_obj):
	var hit_data = caster.invoker.stats.hit({
		source_id = spell_data.id,
		target_node = area_obj.get_parent(), 
		damage_type = spell_data.damage_type,
		damage = spell_data.damage,
		damage_knockback = spell_data.damage_knockback,
		position_normal = direction,
		modifiers = Global.sanitize_modifiers(spell_data.modifiers),
	})
	area_obj.hitted(hit_data)


func _on_area_2d_area_entered(area):
	if !collisions.has(area):
		_apply_dps(area)
		collisions.append(area)


func _on_area_2d_area_exited(area):
	collisions.erase(area)


func _on_timeout_timer_timeout():
	bg.emitting = false
	fg.emitting = false
	
	var tween = create_tween()
	tween.tween_property($sfx, 'volume_db', -40, 1.0)
	collision_area_body.disabled = true
	# collision_area_head.disabled = true
	Global.delay_func(self, 'queue_free', 1.0)
	emit_signal("timeout")



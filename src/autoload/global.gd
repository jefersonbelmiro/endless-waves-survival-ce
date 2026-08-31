extends Node

signal enemy_died(body)
signal player_exp_changed()
signal player_upgrade_points_changed()
signal player_level_changed()
signal player_coins_changed(amount)
signal player_health_changed()
signal player_deaded()
signal player_quit()
signal player_spawned()
signal player_portal_endered()
signal chest_collected()
signal objective_status_changed(status)
signal objectives_completed()
signal game_paused_changed(paused)
signal opened_popups_changed()
signal plataform_initialized()

enum DAMAGE_TYPE { MAGIC, PHYSICAL }
enum ATTACK_TYPE { MELEE, RANGE }

enum CARD_TYPE { WEAPON, SKILL }
enum SKILL_CAST_TYPE { AUTOCAST, ULTIMATE, PASSIVE, SUMMON }
enum CONSUMABLE_TYPE { ITEM, SUMMON }

enum SPELL_TARGET_TYPE { 
	CLOSEST_TARGET,
	RANDOM_TARGET, 
	RANDOM_DIRECTION, 
	RANDON_POSITION,
	AIM_VECTOR,
	TARGET_UNIT,
}


enum OBJECTIVE_STATUS { QUIT, WIN, LOSE }
enum ACTIVATE_PORTAL_MODES { INSTANTLY, ACTION, CHANNELING, }
enum MAP_MODES { OBJECTIVES, ENDLESS }

const THEME_CONFIG = {
	bg_color = Color("#181818"),

	bg_overlay_color = Color("#c9191919"),

	button_bg_color = Color("#75202020"),
	button_bg_hover_color = Color("#000000"),

	panel_bg = Color("#35000000"),
	panel_border = Color("#2b676767"),
}

const COINS_BONUS_COMPLETE_OBJECTIVES = 100
const COINS_BONUS_UNLOCK_MAP_LEVEL = 100
const DECK_CARD_UPGRADE_COST = 5

var session = {
	controller_device = 0,
	current_char_id = null,
	current_map_id = null,
	current_deck_id = null,
	score_bonus = 0,
	map = {
		coins_complete_objectives = 0,
		coins_unlock_level = 0,
		new_high_score = false
	}
}

var log_data = {}
var time_ellapsed = 0
var kills = 0

var map_bounds := Rect2()
var layer_names = []

var game
var player
var map: Node
var floor_container: Node2D
var drop_container: Node2D
var entity_container: Node2D
var hud: CanvasLayer
var hud_spell_slots: Control
var hud_consumable_slots: Control
var hud_toast_container: Control
var hud_objectives_container: Control

# effects
var floating_text_scene = preload("res://src/effects/floating_text/floating_text.tscn")
var leveup_effect_scene = preload("res://src/effects/levelup/levelup_effect.tscn")
var leveup_effect_text = preload("res://src/effects/levelup/levelup_text.tscn")
var dead_effect_scene = preload("res://src/effects/dead_effect/dead_effect.tscn")
var player_dead_effect_scene = preload("res://src/effects/player_dead_effect/player_dead_effect.tscn")
var player_quit_effect_scene = preload("res://src/effects/player_quit_effect/player_quit_effect.tscn")
var player_victory_effect_scene = preload("res://src/effects/player_victory_effect/player_victory_effect.tscn")
var start_effect_scene = preload("res://src/effects/start_effect/start_effect.tscn")
var hit_effect_scene = preload("res://src/effects/hit_effect/hit_effect.tscn")
var floor_hit_effect_scene = preload("res://src/effects/floor_hit_effect/floor_hit_effect.tscn")
var frozen_effect_scene = preload("res://src/effects/frozen_effect/frozen_effect.tscn")
var debuff_poison_effect_scene = preload("res://src/effects/debuff_poison_effect/debuff_poison_effect.tscn")
var debuff_burn_effect_scene = preload("res://src/effects/debuff_burn_effect/debuff_burn_effect.tscn")
var glow_effect_scene = preload("res://src/effects/glow/glow.tscn")
var trail_effect_scene = preload("res://src/effects/trail/trail.tscn")
var trail_particles_effect_scene = preload("res://src/effects/trail_particles/trail_particles.tscn")
var teleport_effect_scene = preload("res://src/effects/teleport_effect/teleport_effect.tscn")
var life_suck_effect_scene = preload("res://src/effects/life_suck_effect/life_suck_effect.tscn")
var world_env_scene = preload("res://src/effects/word_env/world_environment.tscn")
var spawn_effect_scene = preload("res://src/effects/spawn_effect/spawn_effect.tscn")

# components
var joystick_button_scene = preload("res://src/components/joystick_input/joystick_button.tscn")
var solid_button_scene = preload("res://src/components/solid_button/solid_button.tscn")
var book_button_scene = preload("res://src/components/book_button/book_button.tscn")
var box_button_scene = preload("res://src/components/box_button/box_button.tscn")
var card_upgrade_button_scene = preload("res://src/components/card_upgrades_button/card_upgrades_button.tscn")
var deck_card_button_scene = preload("res://src/components/deck_card_button/deck_card_button.tscn")
var hit_box_area_scene = preload("res://src/components/hit_box_area/hit_box_area.tscn")
var target_marker_scene = preload("res://src/components/target_marker/target_marker.tscn")
var portal_scene = preload("res://src/components/portal/portal.tscn")
var passive_caster_scene = preload("res://src/components/passive_caster/passive_caster.tscn")
var toast_scene = preload("res://src/components/toast/toast.tscn")
var drop_scene = preload("res://src/components/drop/drop.tscn")
var hit_box_melee_scene = preload("res://src/components/hit_box_melee/hit_box_melee.tscn")
var input_icon_scene = preload("res://src/components/input_icon/input_icon.tscn")
var locked_icon_scene = preload("res://src/components/locked_icon/locked_icon.tscn")
var input_aim_marker_scene = preload("res://src/components/input_direction_marker/input_direction_marker.tscn")
var aim_mode_controller = preload("res://src/components/aim_mode_controller/aim_mode_controller.tscn")
var crosshair_scene = preload("res://src/components/crosshair/crosshair.tscn")
var phase_controller_scene = preload("res://src/components/phase_controller/phase_controller.tscn")
var async_loader_scene = preload("res://src/components/async_loader/async_loader.tscn")
var bad_words_filter = preload("res://src/components/bad_words_filter/bad_words_filter.tscn")

# enemy projectiles
var ball_projectile_scene = preload("res://src/enemies/projectiles/ball/ball_projectile.tscn") 
var bone_projectile_scene = preload("res://src/enemies/projectiles/bone/bone_projectile.tscn") 
var launch_ball_projectile_scene = preload("res://src/enemies/projectiles/launch_ball/launch_ball_projectile.tscn") 

# popup
var card_edit_popup_scene = preload("res://src/popup/card_edit/card_edit_popup.tscn")
var confirm_popup_scene = preload("res://src/popup/confirm/confirm_popup.tscn")
var score_name_edit_popup_scene = preload("res://src/popup/score_name_edit/score_name_edit_popup.tscn")
var score_detail_popup_scene = preload("res://src/popup/score_detail_popup/score_detail_popup.tscn")

# env textures
var coin_texture = preload("res://src/env/coin/coin.png")
var coins_texture = preload("res://src/env/coin/coins.png")
var experience_texture = preload("res://src/env/experience/experience.png")
var experiences_texture = preload("res://src/env/experience/experiences.png")
var chest_texture = preload("res://src/env/chest/texture/chest1.png")

var main_scene = preload("res://src/main.tscn")
var menu_screen_scene = preload("res://src/screens/menu/menu_screen.tscn")
var critical_damage_bg_texture = preload("res://assets/components/critical_damage_bg.png")
var icon_placeholder_texture = preload("res://assets/icons/icon-placeholder.png")
var icon_poison = preload("res://assets/icons/poison.png") 
var icon_burn = preload("res://assets/icons/burn.png") 
var icon_frozen = preload("res://assets/icons/frozen.png") 

var default_theme = preload("res://src/res/theme.tres")

var custom_fonts = {
	monogram_size_8_border_0 = preload("res://src/res/fonts/monogram_8.tres"),
	monogram_size_12_border_0 = preload("res://src/res/fonts/monogram_12.tres"),
	monogram_size_16_border_0 = preload("res://src/res/fonts/monogram_16.tres"),
	monogram_size_40_border_0 = preload("res://src/res/fonts/monogram_40.tres"),
	silver_size_8_border_0 = preload("res://src/res/fonts/silver_8.tres"),
	silver_size_12_border_0 = preload("res://src/res/fonts/silver_12.tres"),
	silver_size_16_border_0 = preload("res://src/res/fonts/silver_16.tres"),
	silver_size_40_border_0 = preload("res://src/res/fonts/silver_40.tres"),
}

var fonts = {
	monogram = preload("res://assets/fonts/monogram.ttf"),
	silver = preload("res://assets/fonts/Silver.ttf"),
}

var classes = {
	parent_accessor = preload("res://src/classes/parent_accessor.gd")
}

var spawn_id_scene = {
	# basic enemies
	jelly = preload("res://src/enemies/jelly/jelly.tscn"),
	skeleton = preload("res://src/enemies/skeleton/skeleton.tscn"),
	skeleton_bomb = preload("res://src/enemies/skeleton_bomb/skeleton_bomb.tscn"),
	bat = preload("res://src/enemies/bat/bat.tscn"),
	black_bat = preload("res://src/enemies/black_bat/black_bat.tscn"),
	eye = preload("res://src/enemies/eye/eye.tscn"),
	ghost = preload("res://src/enemies/ghost/ghost.tscn"),
	green_caterpillar = preload("res://src/enemies/green_caterpillar/green_caterpillar.tscn") ,
	red_caterpillar = preload("res://src/enemies/red_caterpillar/red_caterpillar.tscn") ,
	
	# mini bosses
	jelly_king = preload("res://src/enemies/mini_bosses/jelly_king/jelly_king.tscn") ,
	skeleton_king = preload("res://src/enemies/mini_bosses/skeleton_king/skeleton_king.tscn"),
	skeleton_king_range = preload("res://src/enemies/mini_bosses/skeleton_king_range/skeleton_king_range.tscn"),
	bat_king = preload("res://src/enemies/mini_bosses/bat_king/bat_king.tscn") ,
	eye_king = preload("res://src/enemies/mini_bosses/eye_king/eye_king.tscn") ,
	ghost_king = preload("res://src/enemies/mini_bosses/ghost_king/ghost_king.tscn") ,
	book = preload("res://src/enemies/mini_bosses/book/book.tscn"),
	serpent_elite = preload("res://src/enemies/mini_bosses/serpent/serpent_elite.tscn"),
	centipede_elite = preload("res://src/enemies/mini_bosses/centipede/centipede_elite.tscn"),
	
	# bosses
	centipede_boss = preload("res://src/enemies/bosses/centipede_boss/centipede_boss.tscn"),
	jelly_boss = preload("res://src/enemies/bosses/jelly_boss/jelly_boss.tscn"),
	skeleton_boss = preload("res://src/enemies/bosses/skeleton_boss/skeleton_boss.tscn"),
	reaper_boss = preload("res://src/enemies/bosses/reaper_boss/reaper_boss.tscn"),

	# mobs
	mob = preload("res://src/enemies/mob/mob.tscn"),

	#env
	crystal = preload("res://src/env/crystal/crystal.tscn"),
	chest = preload("res://src/env/chest/chest.tscn"),

	# npc
	merchant = preload("res://src/npc/merchant/merchant.tscn") ,
}

var chars_scenes = {
	mage = preload("res://src/chars/mage/mage.tscn"),
	rogue = preload("res://src/chars/rogue/rogue.tscn"),
	knight = preload("res://src/chars/knight/knight.tscn"),
	archer = preload("res://src/chars/archer/archer.tscn"),
	druid = preload("res://src/chars/druid/druid.tscn"),
	caveman = preload("res://src/chars/caveman/caveman.tscn"),
}

var chars_spriteframes = {
	mage = preload("res://src/chars/mage/res/mage_spriteframes.tres"),
	rogue = preload("res://src/chars/rogue/res/rogue_spriteframes.tres"),
	knight = preload("res://src/chars/knight/res/knight_spriteframes.tres"),
	archer = preload("res://src/chars/archer/res/archer_spriteframes.tres"),
	druid = preload("res://src/chars/druid/res/druid_spriteframes.tres"),
	caveman = preload("res://src/chars/caveman/res/caveman_spriteframes.tres"),
}

var chars_icons = {
	mage = preload("res://src/chars/mage/texture/idle/mage-idle1.png"),
	rogue = preload("res://src/chars/rogue/texture/idle/rogue_idle1.png"),
	knight = preload("res://src/chars/knight/texture/idle/knight_idle1.png"),
	archer = preload("res://src/chars/archer/texture/idle/archer_idle1.png"),
	druid = preload("res://src/chars/druid/texture/idle/druid_idle1.png"),
	caveman = preload("res://src/chars/caveman/texture/idle/caveman_idle1.png"),
}

var maps_scenes = {
	green_field = preload("res://src/maps/green_field/map_green_field.tscn"),
	skeletal_arena = preload("res://src/maps/skeletal_arena/map_skeletal_arena.tscn"),
	flying_assault = preload("res://src/maps/flying_assault/map_flying_assault.tscn"),
	dota = preload("res://src/maps/dota/map_dota.tscn"),
	treacherous_tombs = preload("res://src/maps/treacherous_tombs/map_treacherous_tombs.tscn"),
	desert = preload("res://src/maps/desert/map_desert.tscn"),
	test = preload("res://src/maps/map_test/map_test.tscn"),
}

var maps_icons = {
	green_field = preload("res://src/maps/green_field/texture/map_green_field_icon.png"),
	skeletal_arena = preload("res://src/maps/skeletal_arena/texture/map_skeletal_arena_icon.png"),
	flying_assault = preload("res://src/maps/flying_assault/texture/map_flying_assault_icon.png"),
	dota = preload("res://src/maps/dota/texture/map_dota_icon.png"),
	treacherous_tombs = preload("res://src/maps/treacherous_tombs/texture/map_treacherous_tombs_icon.png"),
	desert = preload("res://src/maps/desert/texture/map_desert_icon.png"),
}

var maps_icons_bg = {
	green_field = preload("res://src/maps/green_field/texture/map_green_field_bg.png"),
	skeletal_arena = preload("res://src/maps/skeletal_arena/texture/map_skeletal_arena_bg.png"),
	flying_assault = preload("res://src/maps/flying_assault/texture/map_flying_assault_bg.png"),
	dota = preload("res://src/maps/dota/texture/map_dota_bg.png"),
	treacherous_tombs = preload("res://src/maps/treacherous_tombs/texture/map_treacherous_tombs_bg.png"),
	desert = preload("res://src/maps/desert/texture/map_desert_bg.png"),
}

var input_icons_res = {
	mouse_button_index = {
		0: preload("res://assets/input/mouse/button_0.png"),
		1: preload("res://assets/input/mouse/button_1.png"),
		2: preload("res://assets/input/mouse/button_2.png"),
	},
	button_index = {
		0: preload("res://assets/input/button/button_0.png"),
		1: preload("res://assets/input/button/button_1.png"),
		2: preload("res://assets/input/button/button_2.png"),
		3: preload("res://assets/input/button/button_3.png"),
		4: preload("res://assets/input/button/button_4.png"),
		5: preload("res://assets/input/button/button_5.png"),
		6: preload("res://assets/input/button/button_6.png"),
		7: preload("res://assets/input/button/button_7.png"),
	},
	scancode = {
		32: preload("res://assets/input/scancode/32.png"),
		66: preload("res://assets/input/scancode/66.png"),
		69: preload("res://assets/input/scancode/69.png"),
		70: preload("res://assets/input/scancode/70.png"),
		81: preload("res://assets/input/scancode/81.png"),
		82: preload("res://assets/input/scancode/82.png"),
		16777217: preload("res://assets/input/scancode/16777217.png"),
	}
}

const behaviours = {
	chase = preload("res://src/enemies/behaviours/handlers/chase.gd"),
	chase_drops = preload("res://src/enemies/behaviours/handlers/chase_drops.gd"),
	shadow_chase_target = preload("res://src/enemies/behaviours/handlers/shadow_chase_target.gd"),
	seek = preload("res://src/enemies/behaviours/handlers/seek.gd"),
	knockback = preload("res://src/enemies/behaviours/handlers/knockback.gd"),
	range_attack = preload("res://src/enemies/behaviours/handlers/range_attack.gd"),
	launch_attack = preload("res://src/enemies/behaviours/handlers/launch_attack.gd"),
	melee_attack = preload("res://src/enemies/behaviours/handlers/melee_attack.gd"),
	rush_attack = preload("res://src/enemies/behaviours/handlers/rush_attack.gd"),
	move_to_position = preload("res://src/enemies/behaviours/handlers/move_to_position.gd"),
	falling = preload("res://src/enemies/behaviours/handlers/falling.gd"),
	jump = preload("res://src/enemies/behaviours/handlers/jump.gd"),
	teleport = preload("res://src/enemies/behaviours/handlers/teleport.gd"),
	dash = preload("res://src/enemies/behaviours/handlers/dash.gd"),
	launch_node = preload("res://src/enemies/behaviours/handlers/launch_node.gd"),
	shield_formation = preload("res://src/enemies/behaviours/handlers/shield_formation.gd"),
	call_shield_formation = preload("res://src/enemies/behaviours/handlers/call_shield_formation.gd"),
	context_steering = preload("res://src/enemies/behaviours/handlers/context_steering.gd"),
	smash_attack = preload("res://src/enemies/behaviours/handlers/smash_attack.gd"),
	debuff_frozen = preload("res://src/enemies/behaviours/handlers/debuff_frozen.gd"),
	debuff_poison = preload("res://src/enemies/behaviours/handlers/debuff_poison.gd"),
	debuff_burn = preload("res://src/enemies/behaviours/handlers/debuff_burn.gd"),
	find_target = preload("res://src/enemies/behaviours/handlers/find_target.gd"),
	follow_path = preload("res://src/enemies/behaviours/handlers/follow_path.gd"),
	stuck_resolver = preload("res://src/enemies/behaviours/handlers/stuck_resolver.gd"),
}

const behaviours_modifier = {
	debuff_frozen = "debuff_frozen",
	debuff_poison = "debuff_poison",
	debuff_burn = "debuff_burn",
}

const plataforms_sdk = {
	crazygames_scene = preload("res://src/platforms/crazygames/sdk.tscn"),
	steam = preload("res://src/platforms/steam/sdk.tscn"),
}

var opened_popups = []
var opened_popups_focus_control = {}
var time_scale


func _ready():
	randomize()

	reset_data()
	set_settings()
	set_layer_names()
	
	Settings.connect("changed", self, "_on_settings_changed")
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")


func set_nodes_refs():
	game = get_node("/root/main")
	floor_container = get_node("/root/main/floor_container")
	drop_container = get_node("/root/main/drop_container")
	entity_container = get_node("/root/main/entity_container")
	hud = get_node("/root/main/hud")
	hud_spell_slots = get_node("/root/main/hud/container/slots/spell_slots")
	hud_consumable_slots = get_node("/root/main/hud/container/slots/consumable_slots")
	hud_toast_container = get_node("/root/main/hud/front_layer/toast_container")
	hud_objectives_container = get_node("/root/main/hud/container/objectives_container/content")


func reset_data():
	log_data = {
		spell_damage = {},
		spell_level = {},
		player_damage_taken = 0,
		player_level = 1,
		player_deaths = 0,
		coins = 0,
		consumables = {},
	}
	time_ellapsed = 0
	kills = 0
	session.score_bonus = 0
	session.map.coins_complete_objectives = 0
	session.map.coins_unlock_level = 0
	session.map.new_high_score = false


func add_entity(node: Node):
	entity_container.add_child(node)


func add_entity_deferred(node: Node):
	entity_container.call_deferred('add_child', node)
	

func add_drop(node: Node):
	if node.data.group == 'coins' || node.data.group == 'experiences':
		drop_container.call_deferred('add_child', node)
	else:
		add_entity_deferred(node)


func add_toast_error(text: String):
	add_toast(text, { type = Toast.TYPE_ERROR,  })


func add_toast_warn(text: String):
	add_toast(text, { type = Toast.TYPE_WARN, timeout = 3 })


func add_toast(text: String, options = null):
	var control = toast_scene.instance()
	control.text = text
	if options && 'timeout' in options && options.timeout > 0:
		control.timeout = options.timeout
	if options && 'type' in options:
		control.type = options.type
	
	var max_size = 3 if !options || !'max_size' in options else options.max_size
	var curr_size = hud_toast_container.get_child_count()

	# count current new toast
	max_size -= 1

	if curr_size > max_size:
		for index in hud_toast_container.get_child_count():
			var node = hud_toast_container.get_child(index)
			curr_size -= 1
			if node.mark_for_destroy:
				continue
			node.destroy()
			if curr_size <= max_size:
				break

	hud_toast_container.call_deferred("add_child", control)


func remove_toasts(type = -1):
	var size = hud_toast_container.get_child_count()
	for index in size:
		var node = hud_toast_container.get_child(index)
		if type != -1 && node.type != type:
			continue
		if node.mark_for_destroy:
			continue
		node.destroy()


func add_damage_text(amount: float, position: Vector2, color: Color):
	add_floating_text(str(round(amount)), position, color)


func add_critical_damage_text(amount: float, position: Vector2, color: Color):
	add_floating_text(str(round(amount)), position, color, Vector2(1, 1), critical_damage_bg_texture)


func add_miss_text(position: Vector2, color: Color):
	add_floating_text("miss", position, color, Vector2(0.7, 0.7))


func add_lifesteal_text(amount: float, position: Vector2):
	add_floating_text(str(round(amount)), position, Color.green)


func add_floating_text(text: String, position: Vector2, color: Color, scale = Vector2(1, 1), bg_texture = null):
	if !Settings.get_floating_text():
		return
	var node = floating_text_scene.instance()
	# @FIXME centipede change z_index
	node.z_index = 999
	node.text = text
	node.color = color
	node.global_position = position
	node.scale = scale
	node.bg_texture = bg_texture
	game.add_child(node)


func add_hit_box_area(position: Vector2, hit_data, collision_mask, ignore = []):
	var node = create_hit_box_area(position, hit_data, collision_mask, ignore)
	Global.add_entity_deferred(node)
	return node


func add_floor_hit_effect(position: Vector2, area: float, color = Color('#ffffff'), speed_scale = 1):
	var node = create_floor_hit_effect(position, area, color, speed_scale)
	floor_container.call_deferred('add_child', node)


func add_danger_target_marker(position: Vector2, area: float):
	return add_target_marker(position, area, Color('#c9a11414'))


func add_target_marker(position: Vector2, area: float, color = null):
	var node = target_marker_scene.instance()
	node.global_position = position
	node.area = area
	if color:
		node.modulate = color
	floor_container.call_deferred('add_child', node)
	return node


func add_spawn_effect(parent_node: Node2D):
	var node = spawn_effect_scene.instance()
	node.modulate = parent_node.base_color
	parent_node.add_child(node)
	return node


func add_hit_effect(position: Vector2):
	var node = hit_effect_scene.instance()
	node.global_position = position
	game.add_child(node)


func add_start_effect(parent_node: Node2D):
	var node = start_effect_scene.instance()
	if 'base_color' in parent_node:
		node.color = parent_node.base_color
	if 'color' in parent_node:
		node.color = parent_node.color
	node.global_position = parent_node.global_position
	game.add_child(node)
	return node


func add_player_dead_effect(position: Vector2):
	var node = player_dead_effect_scene.instance()
	node.global_position = position
	add_entity(node)
	return node


func add_player_quit_effect(position: Vector2):
	var node = player_quit_effect_scene.instance()
	node.global_position = position
	add_entity(node)


func add_player_victory_effect(position: Vector2):
	var node = player_victory_effect_scene.instance()
	node.global_position = position
	add_entity(node)


func add_hit_box_area_from_source(source: Node2D):
	if !is_instance_valid(source) || !is_instance_valid(source.caster):
		return
	var spell_data = source.caster.get_data()
	var stats = source.caster.invoker.stats
	var area_position = source.global_position
	var hit_data = {
		source_node = source.caster.invoker,
		source_id = source.caster.id,
		area = spell_data.area + stats.spell_area,
		damage_type = spell_data.damage_type,
	}
	if 'damage' in spell_data:
		hit_data.damage = spell_data.damage
	if 'base_damage_factor' in spell_data:
		hit_data.damage = stats.base_damage * spell_data.base_damage_factor
	if 'modifiers' in spell_data:
		hit_data.modifiers = sanitize_modifiers(spell_data.modifiers)
	if 'damage_knockback' in spell_data:
		hit_data.damage_knockback = spell_data.damage_knockback
	if 'position_normal' in source:
		hit_data.position_normal = source.position_normal
	if 'area_position' in source && source.area_position:
		area_position = source.area_position
	if 'area_scale_factor' in source && source.area_scale_factor:
		hit_data.area *= source.area_scale_factor
	return add_hit_box_area(area_position, hit_data, "enemy_hurtbox")


func apply_trait_stack(target_object, stack_data, size: int):
	for key in stack_data.keys():
		if key in target_object && target_object[key] != null:
			var current_value = target_object[key]
			if typeof(current_value) == TYPE_STRING:
				var percent = current_value.ends_with('%')
				current_value = str(float(current_value) + float(stack_data[key]) * size)
				if percent:
					current_value += '%'
			else:
				current_value = target_object[key] + float(stack_data[key]) * size
			target_object[key] = current_value
		else:
			var current_value = stack_data[key]
			if typeof(current_value) == TYPE_STRING:
				var percent = current_value.ends_with('%')
				current_value = str(float(current_value) * size)
				if percent:
					current_value += '%'
			else:
				current_value = float(current_value) * size
			target_object[key] = current_value


func apply_modifier_stack(target_object, stack_data, modifier_keys):
	for key in modifier_keys:
		if key in stack_data && stack_data[key] != null:
			var current_value = target_object[key]
			if typeof(current_value) == TYPE_STRING:
				var percent = current_value.ends_with('%')
				current_value = str(float(current_value) + float(stack_data[key]))
				if percent:
					current_value += '%'
			else:
				current_value = target_object[key] + float(stack_data[key])
			target_object[key] = current_value


func sanitize_modifiers(modifiers_raw):
	var modifiers = {}
	for modifier_id in modifiers_raw.keys():
		var modifier = modifiers_raw[modifier_id]
		if 'proc_chance' in modifier && modifier.proc_chance <= 0:
			continue
		modifiers[modifier_id] = modifier.duplicate(true)
		modifiers[modifier_id].id = modifier_id
	if modifiers.size() == 0:
		return null
	return modifiers


func add_enemy_dead_effect(position: Vector2, color = Color("#ffffff"), amount = 200, scale = 1.0):
	# @FIXME workaround to prevent enemie dead effect in same time to player dead effect
	# whitout this sometimes player and enemie explode to close
	if !Global.player.is_alive():
		return
	return add_dead_effect(position, color, amount, scale)


func add_dead_effect(position: Vector2, color = Color("#ffffff"), amount = 200, scale = 1.0):
	if !Settings.get_particle_effect():
		return
	var node = dead_effect_scene.instance()
	node.global_position = position
	node.color = color
	node.amount = amount
	node.scale = Vector2(scale, scale)
	game.add_child(node)
	return node


func add_portal():
	var node = portal_scene.instance()
	var portal_position = map.get_node_or_null("portal_position")
	if !portal_position:
	   portal_position = map.get_node('start_position')
	node.global_position = portal_position.global_position + Vector2(0, 8)
	add_entity(node)


func add_confirm(label: String, container_size = null):
	var node = confirm_popup_scene.instance()
	node.label_text = label
	if container_size:
		node.container_size = container_size
	var game_front_layer = get_node_or_null("/root/main/hud/front_layer")
	if is_instance_valid(game_front_layer):
		game_front_layer.add_child(node)
	else:
		get_node("/root/menu_screen/front_layer").add_child(node)
	node.open()
	return node


func add_score_edit_popup():
	var node = score_name_edit_popup_scene.instance()
	var game_front_layer = get_node_or_null("/root/main/hud/front_layer")
	if is_instance_valid(game_front_layer):
		game_front_layer.add_child(node)
	else:
		get_node("/root/menu_screen/front_layer").add_child(node)
	node.open()
	return node


func add_score_detail_popup(score_data, rank_index):
	var node = score_detail_popup_scene.instance()
	node.data = score_data
	node.rank_index = rank_index
	var game_front_layer = get_node_or_null("/root/main/hud/front_layer")
	if is_instance_valid(game_front_layer):
		game_front_layer.add_child(node)
	else:
		get_node("/root/menu_screen/front_layer").add_child(node)
	node.open()
	return node


func create_hit_box_area(position: Vector2, hit_data, collision_mask, ignore = []):
	var node = hit_box_area_scene.instance()
	node.global_position = position
	node.data = hit_data
	node.ignore = ignore
	Global.node_set_collision_mask(node, collision_mask)
	return node


func create_floor_hit_effect(position: Vector2, area: float, color = Color('#ffffff'), speed_scale = 1):
	var node = floor_hit_effect_scene.instance()
	node.global_position = position
	node.area = area
	node.color = color
	node.speed_scale = speed_scale
	return node


func create_levelup_effect():
	return leveup_effect_scene.instance()


func create_frozen_effect():
	var node = frozen_effect_scene.instance()
	return node


func create_debuff_poison_effect():
	var node = debuff_poison_effect_scene.instance()
	return node


func create_debuff_burn_effect():
	var node = debuff_burn_effect_scene.instance()
	return node


func create_levelup_text():
	return leveup_effect_text.instance()


func create_joystick_button():
	return joystick_button_scene.instance()


func create_drop(data):
	var node
	if data.id == 'chest':
		node = spawn_id_scene.chest.instance()
	else:
		node = drop_scene.instance()
	node.id = data.id
	node.data = data
	return node


func create_char(id: String):
	var scene = Global.chars_scenes[Global.session.current_char_id]
	var node = scene.instance()
	node.data = Database.get_char(id)
	node.deck = Persistent.get_deck(Global.session.current_deck_id)
	return node


func create_map(id: String):
	var node = get_map_scene(id).instance()
	node.data = Entities.create_map_data(id)
	node.data.load_persisted()
	return node


func create_hit_box_melee(options = null):
	var disabled = FP.safe_get(options, 'disabled', true)
	var collision_radius = FP.safe_get(options, 'collision_radius', 10)
	var collision_mask = FP.safe_get(options, 'collision_mask', 'player_hurtbox')
	var node = hit_box_melee_scene.instance()
	node.collision_radius = collision_radius
	node.disabled = disabled
	node_set_collision_mask(node, collision_mask)
	return node


func node_remove_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()


func remove_all_floor_nodes():
	node_remove_children(floor_container)


func kill_all_enemies(dead_effect = true):
	var enemies = get_tree().get_nodes_in_group("enemies")
	for index in enemies.size():
		var node = enemies[index]
		if !is_instance_valid(node):
			continue
		if dead_effect:
			Global.add_enemy_dead_effect(node.global_position, node.base_color)
		node.queue_free()


func remove_all_non_player_entities():
	for index in entity_container.get_child_count():
		var node = entity_container.get_child(index)
		if !is_instance_valid(node) || node == player:
			continue
		node.queue_free()


func kill_all_summons():
	var summons = get_tree().get_nodes_in_group("summons")
	for index in summons.size():
		var node = summons[index]
		if !is_instance_valid(node):
			continue
		node.queue_free()


func kill_all_drops():
	var drops = get_tree().get_nodes_in_group("drops")
	for index in drops.size():
		var node = drops[index]
		if !is_instance_valid(node) || node.picker:
			continue
		node.queue_free()


func collect_all_coins_experience():
	var drops = get_tree().get_nodes_in_group("drops")
	for index in drops.size():
		var node = drops[index]
		if !is_instance_valid(node):
			continue
		if node.id == 'experience' || node.id == 'coin':
			node.set_picker(Global.player, 5)


func char_set_data(node: Node, data):
	for key in data.stats.keys():
		if node.stats.modifier_keys.has(key):
			node.stats.set_raw_value(key, data.stats[key])
		else:
			node.stats[key] = data.stats[key]

	Traits.apply_player_stats(node)

	node.stats.current_health = node.stats.max_health
	node.add_spell(data.main_card)
	node.add_spell("invulnerability")
	node.apply_modifiers()


func enemy_set_data(node: Node, data):
	node.level = data.level
	if 'drops' in data:
		node.drops = data.drops

	if 'collision_layer' in data:
		node_set_collision_layer(node, data.collision_layer)

	if 'collision_mask' in data:
		node_set_collision_mask(node, data.collision_mask)

	if 'z_index' in data:
		node.z_index = data.z_index

	for key in data.stats.keys():
		if node.stats.modifier_keys.has(key):
			node.stats.set_raw_value(key, data.stats[key])
		else:
			node.stats[key] = data.stats[key]

	if node.level > 1:
		var health_inc = node.stats.max_health * data.buff_per_level.max_health * node.level
		var move_speed_inc = node.stats.move_speed * data.buff_per_level.move_speed * node.level
		var max_move_speed = data.buff_per_level.max_move_speed if 'max_move_speed' in data.buff_per_level else 100
		var base_damage_inc = node.stats.base_damage * data.buff_per_level.base_damage * node.level
		node.stats.set_raw_value('max_health', int(node.stats.max_health + health_inc))
		node.stats.set_raw_value('move_speed', int(min(node.stats.move_speed + move_speed_inc, max_move_speed)))
		node.stats.set_raw_value('base_damage', int(node.stats.base_damage + base_damage_inc))

	Traits.apply_enemy_stats(node)

	node.stats.current_health = node.stats.max_health

	if 'behaviours'in data:
		for behaviour in data.behaviours:
			if typeof(behaviour) == TYPE_STRING:
				node.behaviour_container.add(behaviour)
			else:
				node.behaviour_container.add(behaviour.id, behaviour.data)
	
	# default behaviours
	node.behaviour_container.add_once("find_target")
		

func node_set_collision_layer(node, value):
	node.collision_layer = 0
	if typeof(value) == TYPE_STRING:
		node.set_collision_layer_bit(get_layer(value), true)
	elif typeof(value) == TYPE_ARRAY:
		for layer in value:
			node.set_collision_layer_bit(get_layer(layer), true)


func node_set_collision_layer_deferred(node, value):
	node.set_deferred("collision_layer", 0)
	if typeof(value) == TYPE_STRING:
		node.call_deferred("set_collision_layer_bit", get_layer(value), true)
	elif typeof(value) == TYPE_ARRAY:
		for layer in value:
			node.call_deferred("set_collision_layer_bit", get_layer(layer), true)
	

func node_set_collision_mask(node, value):
	node.collision_mask = 0
	if typeof(value) == TYPE_STRING:
		node.set_collision_mask_bit(get_layer(value), true)
	elif typeof(value) == TYPE_ARRAY:
		for layer in value:
			node.set_collision_mask_bit(get_layer(layer), true)


func node_in_viewport(node: Node2D):
	if !is_instance_valid(game) || !is_instance_valid(node):
		return false
	var position = node.global_position
	if 'collision' in node:
		position += Vector2.ONE * node.collision.shape.radius
	return game.viewport_bounds.has_point(position)


func viewport_has_point(point: Vector2):
	if !is_instance_valid(game):
		return false
	return game.viewport_bounds.has_point(point)


func get_viewport_bounds():
	return game.viewport_bounds


func get_collision_layer_bits(value) -> int:
	var result: int = 0
	if typeof(value) == TYPE_STRING:
		value = [value]
	for layer in value:
		result += int(pow(2, get_layer(layer)))
	return result


# return card cast type enum value(int)
# cast_type: int | string
func get_card_cast_type(cast_type) -> int:
	return FP.enum_value_from_string(Global.SKILL_CAST_TYPE, cast_type) 


# return damage type enum value(int)
# damage_type: int | string
func get_damage_type(damage_type) -> int:
	return FP.enum_value_from_string(Global.DAMAGE_TYPE, damage_type) 
	

func log_player_level(level: int):
	log_data.player_level = level


func log_use_consumable(consumable_id: String):
	if not consumable_id in log_data.spell_damage:
		log_data.consumables[consumable_id] = 0
	log_data.consumables[consumable_id] += 1


func log_spell_damage(spell_id: String, damage: float):
	if not spell_id in log_data.spell_damage:
		log_data.spell_damage[spell_id] = 0
	log_data.spell_damage[spell_id] += damage


func log_player_damage_taken(damage: float):
	log_data.player_damage_taken += damage


func log_spell_level(id: String, level: int):
	log_data.spell_level[id] = level


# @DEPRECATED use map functions
# current using in menu_screen
func calculate_bounds(tilemap):
	var cell_bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D(Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2())
	var margin_position = Vector2(tilemap.cell_size.x, tilemap.cell_size.y)
	var margin_size = Vector2(tilemap.cell_size.x, tilemap.cell_size.y) * 2
	Global.map_bounds = Rect2(cell_to_pixel * cell_bounds.position  + margin_position, cell_to_pixel * cell_bounds.size - margin_size)


# @DEPRECATED use map functions
# current using in menu_screen
func set_camera_bounds(camera: Camera2D, bounds: Rect2, margin = 30):
	var view_size = camera.get_viewport_rect().size
	if map_bounds.size / camera.zoom <= view_size:
		return remove_camera_bounds(camera)

	camera.limit_left = bounds.position.x - margin 
	camera.limit_top = bounds.position.y - margin
	camera.limit_right = bounds.end.x + margin 
	camera.limit_bottom = bounds.end.y + margin


# @DEPRECATED use map functions
# current using in menu_screen
func remove_camera_bounds(camera: Camera2D):
	camera.limit_left = -10000000
	camera.limit_top = -10000000
	camera.limit_right = 10000000
	camera.limit_bottom = 10000000


func has_full_screen():
	return !is_mobile() && !is_plataform_crazygames()
	

func has_quit():
	match OS.get_name():
		"HTML5", "iOS":
			return false
	return true


func is_html():
	return OS.get_name() == "HTML5"


func is_mobile():
	match OS.get_name():
		"Android", "iOS":
			return true
	return false


func is_plataform_steam():
	return OS.has_feature("steam")


func is_plataform_crazygames():
	return OS.has_feature("crazygames")


func set_settings():
	OS.window_fullscreen = Settings.get_setting('general', 'fullscreen')

	default_theme.set_default_font(Global.get_font(16))

	# audio 
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")

	AudioServer.set_bus_mute(music_bus, Settings.has_music_muted())
	AudioServer.set_bus_mute(sfx_bus, Settings.has_sfx_muted())
	AudioServer.set_bus_volume_db(music_bus, Settings.get_music_volume())
	AudioServer.set_bus_volume_db(sfx_bus,  Settings.get_sfx_volume())
	
	TranslationServer.set_locale(Settings.get_language())

	for device_id in Input.get_connected_joypads():
		var device_guid = Input.get_joy_guid(device_id)
		if device_guid == Settings.get_controller_device():
			set_controller_device(device_id)
			break


func set_layer_names():
	layer_names = []
	for index in range(1, 32):
		var layer = ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(index))
		if layer:
			layer_names.append(layer)


func get_layer(layer_name):
	return layer_names.find(layer_name)


func get_font(size: int, border: int = 0, language = null):
	if !language:
		language = Settings.get_language()
	var name = 'monogram' if language.begins_with('en') else 'silver'
	var key = "%s_size_%s_border_%s" % [name, size, border]
	if !custom_fonts.has(key):
		custom_fonts[key] = create_font(name, size, border)
	return custom_fonts.get(key)


func create_font(name: String, size: int, border: int = 0):
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = fonts[name]
	dynamic_font.size = size
	if border:
		dynamic_font.outline_size = border
	return dynamic_font
	

func set_controller_device(device_id: int):
	session.controller_device = device_id
	_remap_input_devices()


func quit():
	# @FIXME wait pressed animation
	yield(get_tree().create_timer(0.15), 'timeout')
	get_tree().quit()


func set_paused(value: bool):
	# pause shaders on paused
	# VisualServer.set_shader_time_scale(0.0 if value else 1.0)
	if value == get_tree().paused || !is_inside_tree():
		return
	get_tree().paused = value
	emit_signal('game_paused_changed', value)


func persist_meta():
	if !is_instance_valid(Global.player):
		return
	var coins = Global.player.coins + Persistent.get_data('meta.coins', 0)
	var backpack = Global.player.backpack.data
	var traits = Traits.current

	var score_data = Persistent.get_score_data()
	var score = calcule_score()
	# var best_score = get_persited_high_score()
	var map_id = map.data.uid

	var traits_used = []
	for trait in traits:
		if !trait || !trait.size || !trait.id:
			continue
		traits_used.append(trait)

	var score_payload = {
		score = score,
		time_ellapsed = time_ellapsed,
		kills = kills,
		map_id = map_id,
		char_id = Global.player.id,
		spell_level = log_data.spell_level,
		player_level = log_data.player_level,
		player_deaths = log_data.player_deaths,
		player_damage_taken = log_data.player_damage_taken,
		coins = log_data.coins,
		consumables = log_data.consumables,
		traits = traits_used,
	}

	if !map_id in score_data.maps || score > score_data.maps[map_id].score:
		score_data.maps[map_id] = score_payload

	if Global.player.is_dead():
		backpack = []
		traits = []

	Persistent.set_data('meta.backpack.data', backpack)
	Persistent.set_data('meta.traits', traits)
	Persistent.set_data('meta.coins', coins)
	Persistent.save_data()

	var sync_score_result = Firebase.sync_score()
	if sync_score_result is GDScriptFunctionState:
		sync_score_result = yield(sync_score_result, "completed")
	if FP.safe_get(sync_score_result, 'error'):
		Global.delay_func(Global, 'add_toast_error', 1.0, { 
			binds = [tr("LEADERBOARD_SEND_SCORE_ERROR")], 
			pause_mode_process = true
		})
	

func drop_radius(drops: Array, position: Vector2, radius = 20, launch_effect = false):
	var size = drops.size()

	if size == 1:
		if !Global.map.spawn_bounds_has_point(position):
			return
		var data = drops[0]
		var node = Global.create_drop(data)
		node.global_position = position
		Global.add_drop(node)
		return

	var length = clamp(size, 0, 6)
	var current_length = 0
	var drop_index = 0
	var safe_it = size + 20
	while length > 0 && current_length < size && safe_it > 0:
		safe_it -= 1
		var radius_vec = Vector2(radius, 0).rotated(deg2rad(randi() % 360))
		var step = 2 * PI / length
		for spawn_index in length:
			var data = drops[drop_index]
			drop_index += 1
			current_length += 1
			var drop_position = position + radius_vec.rotated(step * spawn_index)
			if !Global.map.spawn_bounds_has_point(drop_position):
				continue
			var node = Global.create_drop(data)
			if launch_effect:
				node.global_position = position
				node.set_target_position(drop_position)
			else:
				node.global_position = drop_position
			Global.add_drop(node)
		length = clamp(length * 2, 0, size - current_length)
		radius += 20


# options {
#   popup_tween: bool
#   popup_tween_container: Control
#   popup_tween_finished_func_ref: FuncRef
# }
func opened_popups_add(popup, options = null):
	# @FIXME
	var popup_tween = FP.safe_get(options, 'popup_tween', true)
	var popup_tween_container = FP.safe_get(options, 'popup_tween_container', popup)
	opened_popups.append(popup)
	var focus_control = popup.get_focus_owner()
	if focus_control:
		opened_popups_focus_control[popup] = focus_control.get_path()
	emit_signal("opened_popups_changed")
	if popup_tween: 
		# wait popup to be visible
		yield(get_tree(), 'idle_frame')
		var func_ref = FP.safe_get(options, 'popup_tween_finished_func_ref', null)
		create_popup_tween(popup_tween_container, func_ref)


func opened_popups_remove(popup):
	var focus_control
	if opened_popups_focus_control.has(popup):
		var focus_node = get_node_or_null(opened_popups_focus_control.get(popup))
		if is_instance_valid(focus_node) && focus_node.is_inside_tree():
			focus_control = focus_node
		opened_popups_focus_control.erase(popup)

	opened_popups.erase(popup)
	if focus_control:
		yield(get_tree(), 'idle_frame')
		if is_instance_valid(focus_control):
			focus_control.grab_focus()
	emit_signal("opened_popups_changed")


func create_popup_tween(node, func_ref = null):
	if !is_instance_valid(node):
		return
	node.rect_pivot_offset = node.rect_size / 2
	node.rect_scale = Vector2(0.7, 0.7)
	var tween = create_tween().bind_node(node).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, 'rect_scale', Vector2(1, 1), 0.2)
	if func_ref:
		tween.connect("finished", self, '_on_popup_tween_finished', [func_ref])
	get_tree().create_timer(0.2).connect('timeout', SFX, "add_popup")


func delay_func(object, handler, time_sec = 0.1, options = {}):
	var binds = options.binds if 'binds' in options else []
	var flags = options.flags if 'flags' in options else 0
	var default_pause_mode = true if 'pause_mode' in object && object.pause_mode == PAUSE_MODE_PROCESS else false
	var pause_mode_process = options.pause_mode_process if 'pause_mode_process' in options else default_pause_mode
	get_tree().create_timer(time_sec, pause_mode_process).connect("timeout", object, handler, binds, flags)


var debounce_data = {}
func debounce_func(object, handler, time_sec = 0.1):
	if !debounce_data.has(object):
		debounce_data[object] = {}
	if !debounce_data[object].has(handler):
		var timer_node = Timer.new()
		timer_node.pause_mode = object.pause_mode
		timer_node.one_shot = true
		timer_node.connect("timeout", self, "_on_debounce_timer_timeout", [object, handler])
		add_child(timer_node)
		timer_node.start(time_sec)
		debounce_data[object][handler] = timer_node
	else:
		var timer_node = debounce_data[object][handler]
		timer_node.pause_mode = object.pause_mode
		timer_node.stop()
		timer_node.start(time_sec)


func _on_debounce_timer_timeout(object, handler):
	if debounce_data.has(object) && debounce_data[object].has(handler):
		debounce_data[object][handler].queue_free()
		debounce_data[object].erase(handler)
	if !debounce_data[object].keys():
		debounce_data.erase(object)
	if is_instance_valid(object):
		object.call(handler)


func create_timer(options = null):
	var node = Timer.new()
	node.pause_mode = FP.safe_get(options, 'pause_mode', PAUSE_MODE_INHERIT)
	node.one_shot = FP.safe_get(options, 'one_shot', false) 
	node.autostart = FP.safe_get(options, 'autostart', false) 
	node.wait_time = FP.safe_get(options, 'wait_time', 1.0)  
	if options && 'on_timeout' in options :
		var flags = FP.safe_get(options.on_timeout, 'flags', 0)
		var binds = FP.safe_get(options.on_timeout, 'binds', [])
		var ref =  FP.safe_get(options.on_timeout, 'ref', options.on_timeout) 
		node.connect("timeout", ref[0], ref[1], binds, flags)
	if options && 'parent' in options:
		options.parent.add_child(node)
	return node


func load_crazygames_sdk():
	var node = get_node_or_null("crazygames_sdk")
	if !is_instance_valid(node):
		node = plataforms_sdk.crazygames_scene.instance()
		add_child(node)
	return node


func load_steam_sdk():
	var node = get_node_or_null("steam_sdk")
	if !is_instance_valid(node):
		node = plataforms_sdk.steam.instance()
		add_child(node)
	return node


func get_plataform_sdk():
	var node = null
	if is_plataform_steam():
		node = get_node_or_null("steam_sdk")
	elif is_plataform_crazygames():
		node = get_node_or_null("crazygames_sdk")
	if !is_instance_valid(node):
		return null
	return node


func init_plataform_sdk():
	var node = null
	if is_plataform_steam():
		node = Global.load_steam_sdk()
	if is_plataform_crazygames():
		node = Global.load_crazygames_sdk()
	if is_instance_valid(node):
		node.connect(
			"init_finalized",
			Global,
			'emit_signal',
			['plataform_initialized'],
			CONNECT_ONESHOT
		)
		node.init()
		return node
	emit_signal("plataform_initialized")
	return null


func get_plataform_user_name(object, handler):
	var node = get_plataform_sdk()
	if !is_instance_valid(node):
		return null
	if node.user_name:
		object.callv(handler, [node.user_name])
	if !node.is_connected("user_name_changed", object, handler):
		node.connect("user_name_changed", object, handler, [], CONNECT_ONESHOT)


func get_async_loader():
	var loader = get_node_or_null("async_loader")
	if !loader:
		loader = async_loader_scene.instance()
		add_child(loader)
	return loader


var throttle_data = {}
func throttle_func(object, handler, time_sec = 0.1):
	if !throttle_data.has(object):
		throttle_data[object] = {}
	if !throttle_data[object].has(handler):
		var timer_node = Timer.new()
		timer_node.pause_mode = object.pause_mode
		timer_node.one_shot = true
		timer_node.connect("timeout", self, "_on_throttle_timer_timeout", [object, handler])
		add_child(timer_node)
		timer_node.start(time_sec)
		throttle_data[object][handler] = timer_node
	else:
		throttle_data[object][handler].pause_mode = object.pause_mode


func _on_throttle_timer_timeout(object, handler):
	if throttle_data.has(object) && throttle_data[object].has(handler):
		throttle_data[object][handler].queue_free()
		throttle_data[object].erase(handler)
	if !throttle_data[object].keys():
		throttle_data.erase(object)
	object.call(handler)


func get_persisted_map_score(map_id: String):
	var score_data = Persistent.get_score_data()
	if map_id in score_data.maps:
		return 0
	return score_data.maps[map_id].score


func get_persited_high_score():
	var score = 0
	var score_data = Persistent.get_score_data()
	for map_id in score_data.maps.keys():
		var map_data = score_data.maps[map_id]
		if typeof(map_data) != TYPE_DICTIONARY:
			continue
		if map_data.score > score:
			score = map_data.score
	return score


func get_persited_high_score_data():
	var score = 0
	var map_id_score
	var score_payload = {}
	var score_data = Persistent.get_score_data()
	for map_id in score_data.maps.keys():
		var map_data = score_data.maps[map_id]
		if typeof(map_data) != TYPE_DICTIONARY:
			continue
		if map_data.score > score:
			score = map_data.score
			map_id_score = map_id
			score_payload = map_data
	if !map_id_score:
		return null
	return {
		map_id = map_id_score,
		score = score,
		payload = score_payload,
	}


func calcule_score():
	var kill_score = kills * 0.05
	var coins_score = log_data.coins * 0.1
	var level_score = log_data.player_level * 0.1
	return int(kill_score + coins_score + level_score) + Global.session.score_bonus


func _on_popup_tween_finished(func_ref):
	func_ref.call_func()


func set_time_scale(value: float, duration: float):
	if is_instance_valid(game):
		game.set_time_scale(value, duration)


func remove_current_time_scale():
	if is_instance_valid(game):
		game.remove_current_time_scale()


func has_touchscreen():
	return OS.has_touchscreen_ui_hint()


func stop_main_music():
	if is_instance_valid(game):
		game.music_player.stop()


func resume_main_music():
	if is_instance_valid(game):
		game.music_player.resume()


func get_map_icon(map_id: String):
	if !map_id in maps_icons:
		return Global.icon_placeholder_texture
	return maps_icons[map_id]


func get_map_icon_bg(map_id: String):
	if !map_id in maps_icons_bg:
		return Global.icon_placeholder_texture
	return maps_icons_bg[map_id]


func get_map_scene(map_id: String):
	return maps_scenes[map_id]


func theme_bg(node: Control):
	node.modulate = THEME_CONFIG.bg_color


func theme_bg_overlay(node: Control):
	node.modulate = THEME_CONFIG.bg_overlay_color


func theme_button(node: Button):
	node.bg_color = THEME_CONFIG.button_bg_color
	node.hover_color = THEME_CONFIG.button_bg_hover_color


func theme_panel_bg(node: Control):
	node.modulate = THEME_CONFIG.panel_bg


func theme_panel_border(node: Control):
	node.modulate = THEME_CONFIG.panel_border


func event_create_mob(data):
	var proc_chance = data.proc_chance if 'proc_chance' in data else 0.5
	var interval = data.interval if 'interval' in data else 30
	var level = data.spawn_level if 'spawn_level' in data else 1
	return {
		type = "spawn",
		proc_chance = proc_chance,
		interval = Formatter.format_timer_seconds(interval),
		data = {
			spawn_mode =  "map_bounds",
			max_enemies_alive = 1,
			spawns = [
				{ 
					id = "mob",  
					type = "mob", 
					data = {
						spawn_level = level,
						spawn_id = data.spawn_id, 
						spawn_size = data.spawn_size if 'spawn_size' in data else 1, 
						spawn_type = data.spawn_type, 
						spawn_options = data.spawn_options if 'spawn_options' in data else null,
					}
				}
			]
		}
	}


func event_add_mob_square(event_system, data):
	var dirs = ['column_left', 'column_right', 'row_top', 'row_bottom']
	for index in dirs.size():
		var dir_data = FP.patch_dictionary(data, { spawn_type = dirs[index]})
		event_system.add(event_create_mob(dir_data))


func event_create_reaper(data = {}):
	var proc_chance = data.proc_chance if 'proc_chance' in data else 0.5
	var interval = data.interval if 'interval' in data else "02:00"
	var start = FP.safe_get(data, 'start')
	var spawn_data = FP.safe_get(data, 'spawn_data')
	var event_data = {
		type = "spawn",
		interval = interval,
		proc_chance = proc_chance,
		data = { 
			spawn_mode = { mode = "circle", radius = 200 },
			spawns = [{ 
				id = "reaper_boss",
				min_enemies_alive = 1,
				max_enemies_alive = 1,
				data = {
					drops = {
						coin = { proc_chance = 1.0, value = 500 },
						experience = { proc_chance = 1.0, value = 2000 },
						consumable = { proc_chance = 1.0 },
						chest = { proc_chance = 1.0, value = 5 },
					}
				}
			}],
		}
	}
	if start:
		event_data.start = start
	if spawn_data:
		event_data.data.spawns[0].data = FP.patch_dictionary(
			event_data.data.spawns[0].data,
			spawn_data
		)
	return event_data


func event_add_reaper(event_system, data = {}):
	var event_data = event_create_reaper(data)
	event_system.add(event_data)


func persistent_load_connect(object, handler, args = []):
	if Persistent.loaded:
		object.callv(handler, args)
	else:
		Persistent.connect("loaded", object, handler, args, CONNECT_ONESHOT)


func create_phase_controller(host: Node, phases, options = null):
	var node = phase_controller_scene.instance()
	node.host = host
	node.phases = phases
	node.phase_timeout = FP.safe_get(options, 'phase_timeout') 
	host.add_child(node)


func _on_settings_changed(_key: String):
	set_settings()


func _on_joy_connection_changed(device_id: int, connected: bool):
	var device_guid = Input.get_joy_guid(device_id)
	# disconnected
	if !connected && device_id != 0 && device_id == session.controller_device:
		set_controller_device(0)
	# device is equal settings
	elif connected && device_guid == Settings.get_controller_device():
		set_controller_device(device_id)
	elif connected && Input.is_joy_known(device_id):
		# current connected dont have configured in settings, set connected
		if !Input.get_connected_joypads().has(Settings.get_controller_device()):
			set_controller_device(device_id)


# remap controller device id
func _remap_input_devices():
	for action in InputMap.get_actions():
		for event in InputMap.get_action_list(action):
			if event is InputEventJoypadButton || event is InputEventJoypadMotion:
				event.device = session.controller_device
	

# workaround to container sizes
# @FIXME  
func _on_size_changed():
	var invalid = []
	var focus_control
	for index in opened_popups.size():
		var popup = opened_popups[index]
		if !is_instance_valid(popup):
			invalid.append(popup)
			continue
			
		if !focus_control:
			focus_control = popup.get_focus_owner()
		popup.set_anchors_and_margins_preset(Control.PRESET_WIDE)

	for index in invalid.size():
		opened_popups.erase(invalid[index])


extends Node

signal init_finalized()
signal user_name_changed(user_name)

var user_name = null
var disabled = true
var initialized = false
var sdk
var on_init_ref
var on_backpack_popup_request_ad_finished_ref
var on_new_game_request_ad_finished_ref
var on_restart_request_ad_finished_ref
var on_get_user_ref
var backpack_popup
var backpack_popup_pause_mode

func _ready():
	sdk = JavaScript.get_interface("SDK")
	on_init_ref = JavaScript.create_callback(self, "_on_init") 
	on_backpack_popup_request_ad_finished_ref = JavaScript.create_callback(self, "_on_backpack_popup_request_ad_finished") 
	on_new_game_request_ad_finished_ref = JavaScript.create_callback(self, "_on_new_game_request_ad_finished") 
	on_restart_request_ad_finished_ref = JavaScript.create_callback(self, "_on_restart_request_ad_finished") 
	on_get_user_ref = JavaScript.create_callback(self, "_on_get_user_finished") 
	

func init():
	if initialized:
		return;
	if !is_instance_valid(sdk):
		push_error("Invalid crazygames sdk")
		return
	sdk.init(on_init_ref)


func play():
	if !_is_sdk_valid():
		get_tree().change_scene_to(Global.main_scene)
		return

	Global.set_paused(true)
	sdk.request_midgame(on_new_game_request_ad_finished_ref)


func gameplay_start():
	if !_is_sdk_valid():
		return
	sdk.gameplay_start()


func gameplay_stop():
	if !_is_sdk_valid():
		return
	sdk.gameplay_stop()


func restart():
	if !_is_sdk_valid():
		Global.set_paused(false)
		get_tree().reload_current_scene();
		return

	gameplay_stop()
	sdk.request_midgame(on_restart_request_ad_finished_ref)


func get_user():
	if !_is_sdk_valid():
		return
	sdk.get_user(on_get_user_ref)


# func persist_data(key, data):
# 	if !_is_sdk_valid():
# 		return FAILED
# 	var result = sdk.persist_data(key, data)
# 	if result == true:
# 		return OK
# 	else:
# 		return FAILED


# func load_data(key):
# 	if !_is_sdk_valid():
# 		return null
# 	var result = sdk.load_data(key)
# 	return result


# func migrate_persited_file():
# 	var raw_data = Encryptor.decrypt_file(Persistent.file_path, Persistent.CRYPTO_KEY)
# 	if raw_data:
# 		var error = =persist_data(Persistent.FILE_NAME, raw_data)
# 		if error == OK:
# 			# rename old file to prefix old, just in case
# 			pass


func show_banners():
	if !_is_sdk_valid():
		return
	sdk.show_banners()


func hide_banners():
	if !_is_sdk_valid():
		return
	sdk.hide_banners()


# @TODO handle async initialization
func configure_menu_screen(menu_screen):
	if !_is_sdk_valid():
		return
	var title_container = menu_screen.get_node_or_null('hud/control/container/title_container')
	if !is_instance_valid(title_container):
		return push_error("not found title container")
	title_container.margin_top = 20

	menu_screen.get_node("hud/new_game_popup").connect("visibility_changed", self, "_on_menu_popup_visibility_changed", [menu_screen])
	menu_screen.get_node("hud/settings_popup").connect("visibility_changed", self, "_on_menu_popup_visibility_changed", [menu_screen])
	menu_screen.get_node("hud/help_popup").connect("visibility_changed", self, "_on_menu_popup_visibility_changed", [menu_screen])


func configure_backpack_edit_popup(popup):
	if initialized:
		return _on_configure_backpack_edit_initialized(popup)

	popup.connect(
		"tree_exiting", 
		popup, 
		"disconnect", [
			"init_finalized", 
			self, 
			"_on_configure_backpack_edit_initialized"
		], 
		CONNECT_DEFERRED | CONNECT_ONESHOT | CONNECT_REFERENCE_COUNTED
	)
	connect(
		"init_finalized", 
		self, 
		"_on_configure_backpack_edit_initialized",
		[popup],
		CONNECT_DEFERRED | CONNECT_ONESHOT | CONNECT_REFERENCE_COUNTED
	)


func configure_game(game):
	game.connect("tree_exiting", Global, "disconnect", ["game_paused_changed", self, "_on_game_paused_changed"])
	Global.connect("game_paused_changed", self, "_on_game_paused_changed")
	gameplay_start()


func _on_game_paused_changed(paused):
	if paused: 
		gameplay_stop()
	else:
		gameplay_start()

 
func _is_sdk_valid():
	if !is_instance_valid(sdk):
		return false
	return initialized && !disabled   


func _on_init(args):
	disabled = args[0]
	initialized = true
	emit_signal("init_finalized")
	get_user()


func _on_configure_backpack_edit_initialized(popup):
	if !_is_sdk_valid():
		return
	backpack_popup = popup
	backpack_popup_pause_mode = popup.pause_mode
	
	var actions_container = popup.get_node("container/content/selected/content")
	if (!actions_container.get_node_or_null("add_coins")):
		var add_coins_node = Global.solid_button_scene.instance()
		add_coins_node.rect_min_size.y = 40
		add_coins_node.border_color = Color('#45dfdd5e')
		add_coins_node.name = "add_coins"
		add_coins_node.text_label = "EARN_100_COINS_AD"
		add_coins_node.connect("pressed", self, "_on_add_coins_pressed")

		actions_container.add_child(add_coins_node)
	

func _on_menu_popup_visibility_changed(menu_screen):
	var settings_popup = menu_screen.get_node("hud/settings_popup")
	var help_popup = menu_screen.get_node("hud/help_popup")
	var new_game_popup = menu_screen.get_node("hud/new_game_popup")
	var hide_banners = new_game_popup.visible || settings_popup.visible || help_popup.visible
	if hide_banners:
		sdk.hide_banners()
	else:
		sdk.show_banners()


func _on_add_coins_pressed():
	if !is_instance_valid(sdk):
		return
	backpack_popup.pause_mode = PAUSE_MODE_STOP
	Global.set_paused(true)
	sdk.request_rewarded(on_backpack_popup_request_ad_finished_ref)


func _on_backpack_popup_request_ad_finished(args):
	backpack_popup.pause_mode = backpack_popup_pause_mode
	Global.set_paused(false)

	var error = !!args[0]

	if error:
		SFX.add_button_error()
		return Global.add_toast_error("Error on get AD")

	if !is_instance_valid(backpack_popup):
		SFX.add_button_error()
		return push_error("crazygames sdk: invalid backpack popup instance")

	backpack_popup.coins += 100
	backpack_popup.meta_bar.set_coins(backpack_popup.coins)

	if !backpack_popup.options.use_player_backpack:
		Persistent.set_data('meta.coins', backpack_popup.coins)
		Persistent.save_data()
	elif is_instance_valid(Global.player):
		Global.player.coins = backpack_popup.coins
		Global.emit_signal('player_coins_changed', backpack_popup.coins)

	Global.add_toast(tr("EARNED_100_COINS_AD"))
	SFX.add_coin()
	

func _on_new_game_request_ad_finished(args):
	Global.set_paused(false)
	var error = !!args[0]

	if error:
		push_error("Error on get AD")

	get_tree().change_scene_to(Global.main_scene)
	

func _on_restart_request_ad_finished(args):
	var error = !!args[0]

	if error:
		push_error("Error on get AD")

	Global.set_paused(false)
	get_tree().reload_current_scene();


func _on_get_user_finished(args):
	var error = !!args[0]

	if error:
		push_error("Error on get AD")

	user_name = FP.safe_get(args[1], 'username')
	emit_signal("user_name_changed", user_name)



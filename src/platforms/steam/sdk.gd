extends Node	

signal user_name_changed(user_name)
signal init_finalized()

var user_name = null

func init():
	var steam = get_node_or_null("/root/Steam")
	emit_signal("init_finalized")
	if !steam || !steam.is_init():
		return

	user_name = steam.friends.get_persona_name()
	emit_signal("user_name_changed", user_name)

	# var steam_id = steam.user.get_steam_id().get_account_id()
	# var persona_name = steam.friends.get_persona_name()
	# var friends = steam.friends.request_user_information(steam_id, false)
	# var friend_name = steam.friends.get_friend_persona_name(steam_id)

	# steam.friends.set_rich_presence("gamestatus", "Winning")
	# steam.friends.set_rich_presence("score", "32")
	# steam.friends.set_rich_presence("steam_display", '#StatusWithScore')
	# steam.friends.clear_rich_presence()

	# overlay
	steam.friends.connect("game_overlay_activated", self, "_on_game_overlay_activated")


func _on_game_overlay_activated(active):
	Global.set_paused(active)


func migrate_persited_file():
	var base = "%s/data" % [OS.get_executable_path().get_base_dir()]
	var path = "%s/%s" % [base, Persistent.FILE_NAME]
	var file = File.new()
	var dir = Directory.new()
	# create data diretory if not exits
	if !dir.dir_exists(base):
		var res = dir.make_dir(base)
		if res != OK:
			return
	# new file exits
	if file.file_exists(path):
		Persistent.file_path = path
		return 
	# old file exits
	elif file.file_exists(Persistent.file_path):
		var res = dir.copy(Persistent.file_path, path)
		if res != OK:
			return
	# migrated or not exits
	Persistent.file_path = path



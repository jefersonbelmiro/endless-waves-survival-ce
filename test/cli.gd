#!/usr/bin/env -S godot --no-window -s
extends SceneTree

var main_script = preload("res://test/framework/main.gd")

func _init():
	var main = Node2D.new()
	main.set_script(main_script)
	get_root().add_child(main)

	# process command line args
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			var key = key_value[0].lstrip("--")
			if key in main.options:
				main.options[key] = key_value[1]

	var start_time = OS.get_ticks_msec()
	var result = main.execute()
	var elapsed = OS.get_ticks_msec() - start_time
	var exit_code = int(!result)

	print("\nsuites: %s/%s | tests: %s/%s | asserts: %s/%s | time: %s ms" % [
		main.suites - main.suites_fails, main.suites, 
		main.tests - main.tests_fails, main.tests, 
		main.asserts - main.asserts_fails, main.asserts,
		elapsed 
	])

	quit(exit_code)

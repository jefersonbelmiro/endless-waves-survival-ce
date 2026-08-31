extends Node

var suites = 0
var suites_fails = 0

var tests = 0
var tests_fails = 0

var asserts = 0
var asserts_fails = 0
var options = { 
	file = null
}

func execute():
	var files = get_files_in_directory("res://test/unit")

	for index in files.size():
		var fails = 0 
		var path = files[index]

		if options.file && !options.file in path:
			continue

		suites += 1
		var script = load(path)
		var file = script.new()

		if suites > 1:
			print("")
		var title = file.title()
		if !title:
			title += "%s" % [path.replace("res://test/unit/", "")]
		print(title)

		for method in file.get_method_list():
			if method.name.begins_with("test_"):

				file._fails = []
				file._asserts = 0
				file.call(method.name)

				tests += 1
				tests_fails += 1 if file._fails.size() else 0
				fails += file._fails.size()
				asserts += file._asserts
				asserts_fails += file._fails.size()
				_format_result(file, method.name)

		if fails > 0:
			suites_fails += 1

	return suites_fails == 0


func _format_result(file, method_name):
	var result = file._fails.size() == 0
	var label = method_name.replace("test_", "").replace("_", " ")
	
	if result:
		print('  ✔︎ ',  label)
	else:
		print('  ✖ ', label)
		for fail in file._fails:
			if fail:
				print("    - %s" % [fail])
	return result


func _process_test(object, method):
	var result = object.call(method)
	var label = "label"
	if result:
		print('  ✔︎ ',  label)
	else:
		print( '  ✖ ', label)
	return result


func _describe(method: String):
	var label = method.replace("test_", "").replace("_", " ")
	print(label)


func get_files_in_directory(path: String, extension = ".gd") -> Array:
	var files = []
	var dir = Directory.new()

	if dir.open(path) == OK:
		dir.list_dir_begin(true, false)
		_add_dir_contents(dir, files, extension)
	else:
		push_error("An error occurred when trying to access the path: " + path)

	return files


func _add_dir_contents(dir: Directory, files: Array, extension: String):
	var file_name = dir.get_next()

	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name
		if dir.current_is_dir():
			files.append_array(get_files_in_directory(path))
		elif !extension || file_name.ends_with(extension):
			files.append(path)

		file_name = dir.get_next()

	dir.list_dir_end()


# useful to create subclases
func _get_inner_classes(script):
	print(" - ", script.get_script_constant_map())
	

# maybe create a scripting language for tests
func _create_gdscript():
	var script = GDScript.new()
	script.source_code = "extends Reference\n\nfunc _init():\n   print('ahhahah')"
	script.reload()

	var instance = script.new()
	print(" - ", script, instance)
	

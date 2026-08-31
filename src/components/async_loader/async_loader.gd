extends Node

signal progress_changed(data)
signal loaded()
signal queue_completed()

var wait_frames
var time_max = 100 # msec

var queue = []
var queue_data = {}
var current_loader: ResourceInteractiveLoader
var current_path: String


func _ready():
	set_process(false)


func _process(_delta):
	# Wait for frames to let the "loading" animation show up.
	if wait_frames > 0:
		wait_frames -= 1
		return

	if !queue.size():
		emit_signal("queue_completed")
		set_process(false)
		return

	if !current_path || !current_loader:
		_pop_queue()

	if !current_loader:
		set_process(false)
		return

	if current_loader:
		_poll()


func start():
	set_process(true)
	wait_frames = 10


func add_queue(path: String):
	if queue.has(path):
		push_error("resource already added to queue: %s" % [path])
		return
	queue.append(path)
	queue_data[path] = {
		current = -1,
		count = -1,
		progress = 0,
		loaded = false,
		error = null,
		resource = null,
	}


func get_resource(path: String):
	if !queue_data.has(path):
		push_error("resource not queued: %s, call builtin load()" % [path])
		return load(path)
	if !queue_data[path].loaded:
		push_error("resource not loaded: %s, call builtin load()" % [path])
		return load(path)
	return queue_data[path].resource


func _pop_queue():
	if !queue.size():
		return null
	current_path = queue[0]
	current_loader = ResourceLoader.load_interactive(current_path)
	if current_loader == null: 
		return null
	queue.remove(0)
	return true


func _set_queue_data(path: String, data: Dictionary):
	queue_data[path] = FP.patch_dictionary(queue_data[path], data)


func _poll():
	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		# Poll resource
		var err = current_loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			var resource = current_loader.get_resource()
			_set_queue_data(current_path, { loaded = true, resource = resource })
			emit_signal("progress_changed", queue_data[current_path])
			current_loader = null
			break
		elif err == OK:
			update_progress()
		else: # Error during loading.
			_set_queue_data(current_path, { loaded = false, error = 'error during loading' })
			current_loader = null
			break

		
func update_progress():
	var progress = float(current_loader.get_stage()) / current_loader.get_stage_count()
	_set_queue_data(current_path, {
		current = current_loader.get_stage(),
		count = current_loader.get_stage_count(),
		progress = progress
	})
	emit_signal("progress_changed", queue_data[current_path])


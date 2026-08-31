extends ScrollContainer

export (Vector2) var delta_for_swipe := Vector2(8, 8) 

var look_for_swipe := false
var swiping := false
var swipe_start : Vector2
var swipe_mouse_start : Vector2
var swipe_mouse_times := []
var swipe_mouse_positions := []
var tween : Tween


func _input(ev) -> void:
	if !Global.is_mobile() || !is_visible_in_tree():
		return
		
	if ev is InputEventScreenTouch:
		
		if ev.pressed and get_global_rect().has_point(ev.position):
			look_for_swipe = true
			swipe_mouse_start = ev.position
			
		elif swiping:
			swipe_mouse_times.append(OS.get_ticks_msec())
			swipe_mouse_positions.append(ev.position)
			var source := Vector2(get_h_scroll(), get_v_scroll())
			var idx := swipe_mouse_times.size() - 1
			var now := OS.get_ticks_msec()
			var cutoff := now - 100
			for i in range(swipe_mouse_times.size() - 1, -1, -1):
				if swipe_mouse_times[i] >= cutoff: 
					idx = i
				else: break
			var flick_start : Vector2 = swipe_mouse_positions[idx]
			var flick_dur := min(0.3, (ev.position - flick_start).length() / 1000)
			if flick_dur > 0.0:
				tween = Tween.new()
				add_child(tween)
				var delta : Vector2 = ev.position - flick_start
				var target := source - delta * flick_dur * 15.0
				tween.interpolate_method(self, 'set_h_scroll', source.x, target.x, flick_dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				tween.interpolate_method(self, 'set_v_scroll', source.y, target.y, flick_dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				tween.interpolate_callback(tween, flick_dur, 'queue_free')
				tween.start()
			swiping = false
			swipe_mouse_times = []
			swipe_mouse_positions = []
			
		else:
			look_for_swipe = false
			
	if ev is InputEventScreenDrag:
			
		if look_for_swipe:
			var delta = ev.position - swipe_mouse_start
			if abs(delta.x) > delta_for_swipe.x or abs(delta.y) > delta_for_swipe.y:
				swiping = true
				look_for_swipe = false
				swipe_start = Vector2(get_h_scroll(), get_v_scroll())
				swipe_mouse_start = ev.position
				swipe_mouse_times = [OS.get_ticks_msec()]
				swipe_mouse_positions = [swipe_mouse_start]
				if is_instance_valid(tween) and tween is Tween:
					tween.stop_all()
		
		if swiping:
			var delta : Vector2 = ev.position - swipe_mouse_start
			set_h_scroll(int(swipe_start.x - delta.x))
			set_v_scroll(int(swipe_start.y - delta.y))
			swipe_mouse_times.append(OS.get_ticks_msec())
			swipe_mouse_positions.append(ev.position)
			ev.position = Vector2.ZERO

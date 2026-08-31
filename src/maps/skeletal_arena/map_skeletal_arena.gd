extends MapBase     

func _ready():
	Global.event_add_reaper(event_system, { start = '15:00', })

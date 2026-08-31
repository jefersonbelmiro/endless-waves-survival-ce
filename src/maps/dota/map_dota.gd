extends MapBase

var ancient

func _ready():
	ancient = Global.spawn_id_scene.crystal.instance()
	ancient.global_position = $ancient_position.global_position
	Global.add_entity(ancient)

	Global.connect("objectives_completed", self, "_on_objectives_completed")
	Global.event_add_reaper(event_system, { start = '15:00', })


func _on_objectives_completed():
	ancient.queue_free()


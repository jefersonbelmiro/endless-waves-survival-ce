extends Particles2D

func _ready():
	Settings.connect("changed", self, "_on_settings_changed")


func _on_bg_particles_visibility_changed():
	emitting = Settings.get_particle_effect()

 
func _on_settings_changed(key: String):
	if key == 'general.particle_effect':
		emitting = Settings.get_particle_effect()

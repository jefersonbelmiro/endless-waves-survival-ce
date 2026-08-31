extends Node2D

# Speed at which the laser extends when first fired, in pixels per seconds.
export var cast_speed := 7200.0
# Maximum length of the laser in pixels.
export var max_length := 150.0
# Base duration of the tween animation in seconds.
export var growth_time := 0.1

# If `true`, the laser is firing.
# It plays appearing and disappearing animations when it's not animating.
# See `appear()` and `disappear()` for more information.
var is_casting := false setget set_is_casting
var direction = Vector2.RIGHT

onready var ray_cast: RayCast2D = $ray_cast
onready var fill_line: Line2D = $fill_line
onready var line_width = fill_line.width
onready var tween = $tween

func _ready():
	set_physics_process(false)
	fill_line.points[1] = Vector2.ZERO
	
	
func _input(event):
	if event is InputEventMouseButton && event.pressed:
		set_is_casting(!is_casting)
	

func _physics_process(delta: float) -> void:
	direction = global_position.direction_to(get_global_mouse_position())
	ray_cast.cast_to = (ray_cast.cast_to + direction * cast_speed * delta).limit_length(max_length)
	cast_beam()
	

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	if is_casting:
		ray_cast.cast_to = Vector2.ZERO
		fill_line.points[1] = ray_cast.cast_to
		appear()
	else:
		# Reset the laser endpoint
		fill_line.points[1] = Vector2.ZERO
		
#		collision_particles.emitting = false
		disappear()

	set_physics_process(is_casting)
#	beam_particles.emitting = is_casting
#	casting_particles.emitting = is_casting
	

# Controls the emission of particles and extends the Line2D to `cast_to` or the ray's 
# collision point, whichever is closest.
func cast_beam() -> void:
	var cast_point := ray_cast.cast_to

	ray_cast.force_raycast_update()
#	collision_particles.emitting = is_colliding()

	if ray_cast.is_colliding():
		cast_point = to_local(ray_cast.get_collision_point())
#		collision_particles.global_rotation = ray_cast.get_collision_normal().angle()
#		collision_particles.position = cast_point

	fill_line.points[1] = cast_point
#	beam_particles.position = cast_point * 0.5
#	beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5


func appear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(fill_line, "width", 0, line_width, growth_time * 2)
	tween.start()


func disappear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(fill_line, "width", fill_line.width, 0, growth_time)
	tween.start()

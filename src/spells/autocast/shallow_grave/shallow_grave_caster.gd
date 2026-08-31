extends BaseCaster

var cooldown_elapsed: float = 0
var casting = false
var allow_cast = false
var blink_tween: SceneTreeTween

onready var duration_timer = $duration_timer

func _ready():
	var modifier = ShallowGraveData.new(get_data())
	modifier.caster = self
	modifier.invoker = invoker
	modifier.connect("activated", self, "_on_modifer_activated")
	invoker.stats.add_modifier(modifier)


func _process(delta: float):
	if !can_cast():
		return

	cooldown_elapsed += delta

	var cooldown = get_cooldown()
	if !allow_cast && !casting && cooldown_elapsed >= cooldown:
		allow_cast = true

	if casting:
		update_cooldown(cooldown)
	else:
		update_cooldown(cooldown - cooldown_elapsed)


func _cast():
	if !allow_cast || casting || !caster.is_alive():
		return
	casting = true
	duration_timer.start(get_duration())
	SFX.add_shield_spell()


func _on_modifer_activated():
	_cast()


func _on_duration_timer_timeout():
	casting = false
	allow_cast = false
	cooldown_elapsed = 0
	reset_cooldown()


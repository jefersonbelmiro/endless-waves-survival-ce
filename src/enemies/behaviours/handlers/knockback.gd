extends Behaviour
class_name KnockbackBehaviour

var knockback_force = 0
var knockback_direction = Vector2.ZERO
# var group_move_disabled = false


func _init():
	group_id = "debuff"


func _ready():
	host.stats.connect("hitted", self, "_on_stats_hitted")


func _process(_delta):
	if disabled || !knockback_force:
		return

	host.velocity = knockback_direction * knockback_force

	knockback_force = lerp(knockback_force, 0, 0.1)
	if knockback_force < 1:
		knockback_force = 0

		if container.groups.move.disabled || host.is_disabled():
			host.velocity = Vector2.ZERO

		# if group_move_disabled:
		# 	container.enable_group("move")
		# 	group_move_disabled = false


func hitted(result: Dictionary):
	if !'damage_knockback' in result || !result.damage_knockback:
		return
	if 'position_normal' in result:
		knockback_direction = result.position_normal
	else:
		knockback_direction = (host.global_position - result.position).normalized()

	knockback_force = result.damage_knockback

	# if container.has_group("move") && !container.disabled_group("move"):
	# 	group_move_disabled = true
	# 	container.disable_group("move")


func _on_stats_hitted(result: Dictionary):
	hitted(result)

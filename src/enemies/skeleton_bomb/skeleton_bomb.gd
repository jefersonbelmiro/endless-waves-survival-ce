extends TargetBase


func _ready():
	var explosion_attack_data = { collision_radius = 16 }
	behaviour_container.set("explosion_attack", ExplosionAttackBehaviour.new(), explosion_attack_data)


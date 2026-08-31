extends HBoxContainer

var coins: int

onready var coins_label = $coins/label


func _ready():
	if Persistent.loaded:
		set_coins(Persistent.get_coins())
	else:
		Persistent.connect("loaded", self, "_on_persistent_loaded")


func _on_persistent_loaded():
	set_coins(Persistent.get_coins())


func set_coins(value: int):
	coins = value
	coins_label.text = str(coins)

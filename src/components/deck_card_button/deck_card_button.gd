extends BoxButton

export var cast_type: int


var _colors = {
	Global.SKILL_CAST_TYPE.AUTOCAST: Color('#16221b'), #Color('#0d1026ac'),
	Global.SKILL_CAST_TYPE.PASSIVE: Color('#221616'),
	Global.SKILL_CAST_TYPE.ULTIMATE: Color('#162122'),
	Global.SKILL_CAST_TYPE.SUMMON: Color('#161f22'),
}

#func _ready():
#	bg_color = _colors[cast_type]

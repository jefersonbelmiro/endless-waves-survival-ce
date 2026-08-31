class_name Formatter

static func format_percent(value):
	var percentage = value * 100
	if str(percentage).find('.') != -1:
		return "%.2f%%" % [percentage]
	return "%s%%" % [percentage]

 
static func format_damage_type(value):
	var damage_type = Global.get_damage_type(value)
	var key = "DAMAGE_TYPE_" + Global.DAMAGE_TYPE.keys()[damage_type].to_upper() 
	return DataFormatter.tr(key)


static func format_short_seconds(value):
	return "%s%s" % [value, DataFormatter.tr('SHORT_SECONDS')]


static func format_per_seconds(value):
	return "%s/%s" % [value, DataFormatter.tr('SHORT_SECONDS')]


static func format_ellapsed(ellapsed: int):
	var seconds = ellapsed % 60
	var minutes = ellapsed % 3600 / 60.0
	var hours = ellapsed / 60.0 / 60.0
	if hours < 1:
		return "%02d:%02d" % [minutes, seconds]
	else:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	

static func format_number(number, separator = '.'):
	var n = str(int(number))
	var size = n.length()
	var s = ""
	for i in range(size):
			if((size - i) % 3 == 0 and i > 0):
				s = str(s, separator, n[i])
			else:
				s = str(s,n[i])
	return s


static func format_timer_seconds(value):
	if typeof(value) != TYPE_STRING:
		return value
	var parts = value.split(":")
	var result = 0
	# hours:minutes:seconds
	if parts.size() == 3:
		result += int(parts[0]) * 60 * 60
		result += int(parts[1]) * 60
		result += int(parts[2])
	# minutes:seconds
	elif parts.size() == 2:
		result += int(parts[0]) * 60
		result += int(parts[1]) 
	# seconds
	elif parts.size() == 1:
		result += int(parts[0])
	return result



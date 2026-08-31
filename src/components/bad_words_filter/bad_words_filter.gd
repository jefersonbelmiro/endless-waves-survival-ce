extends Node

var file_path = 'res://src/components/bad_words_filter/res/profanity_list.txt'
var delimiters = [' ', '_', '-']
var profanity_list = []


func validate(text: String):
	if !profanity_list.size():
		_load()
	for delimiter in delimiters:
		for word in text.split(delimiter):
			if profanity_list.has(word):
				return false
	return true


func _load():
	var file = File.new()
	var opened = file.open(file_path, File.READ)
	if opened != OK:
		push_error("error on open file: %s" % [file_path])
		return
	profanity_list = file.get_as_text().split("\n")

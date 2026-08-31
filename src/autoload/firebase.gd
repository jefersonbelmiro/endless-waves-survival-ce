extends Node

signal leaderboard_loaded(error)
signal leaderboard_changed()

const FIREBASE_CONFIG_PATH := "res://firebase.json"
const SIGN_UP_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
const SIGN_IN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const LEADERBOARD_SIZE = 10

var api_key := ""
var firebase_url := ""

var score_data := {}
var leaderboard
var leaderboard_last_fetch_time: float
var initialized = false

func _init():
	_load_config()


func _load_config():
	var file = File.new()
	if !file.file_exists(FIREBASE_CONFIG_PATH):
		push_warning("firebase.json not found; online leaderboard will be disabled")
		return
	var error = file.open(FIREBASE_CONFIG_PATH, File.READ)
	if error != OK:
		push_warning("Failed to read firebase.json; online leaderboard will be disabled")
		return
	var parsed = JSON.parse(file.get_as_text())
	file.close()
	if parsed.error != OK:
		push_warning("Invalid firebase.json; online leaderboard will be disabled")
		return
	var data = parsed.result
	if typeof(data) == TYPE_DICTIONARY:
		api_key = str(data.get("api_key", ""))
		firebase_url = str(data.get("firebase_url", ""))

func init():
	initialized = true
	score_data = Persistent.get_score_data()
	leaderboard = score_data.leaderboard

	if !score_data.user_name:
		Global.get_plataform_user_name(self, "_on_platform_user_name_changed")

	# ignore if last fetch is less than 5min and player dont hit new high score
	if !Global.session.map.new_high_score && leaderboard_last_fetch_time \
			&& OS.get_system_time_secs() < leaderboard_last_fetch_time + 300:
		emit_signal("leaderboard_loaded", false)
		return null

	var valid_token = yield(update_token(), "completed")
	if !valid_token:
		emit_signal("leaderboard_loaded", true)
		return null

	var leaderboard_response = yield(get_leaderboard(), "completed")
	if leaderboard_response:                              	
		leaderboard_last_fetch_time = OS.get_system_time_secs()
		var changed = _leaderboard_changed(leaderboard_response)
		if changed:
			leaderboard = leaderboard_response
			score_data.leaderboard = leaderboard
			Persistent.set_data('score_data', score_data)
			Persistent.save_data()
		emit_signal("leaderboard_loaded", false)
		emit_signal("leaderboard_changed")
	else:
		emit_signal("leaderboard_loaded", true)

	sync_score()


func update_token():
	if !initialized:
		return false
	var token_expired = false
	if score_data.token_expires:
		token_expired = score_data.token_expires <= OS.get_system_time_secs() + 300
	if !score_data.token || token_expired:
		var login_response = yield(login_or_sign_up(), "completed")
		if login_response.error:
			return false
		score_data.token = login_response.data.idToken
		score_data.token_expires = OS.get_system_time_secs() + int(login_response.data.expiresIn)
		Persistent.set_data('score_data', score_data)
		Persistent.save_data()
	else:
		yield(get_tree(), 'idle_frame')
	return true


func sync_score():
	if !initialized:
		return null
	if !score_data.user_name:
		return null
	var best_score_data = Global.get_persited_high_score_data()
	if !best_score_data:
		return null
	if best_score_data.score > score_data.last_score_sended:
		var result = update_score()
		if result is GDScriptFunctionState:
			return yield(result, "completed")
	return null


func get_leaderboard():
	var response = yield(get_document("scoreboard_v2", { orderBy = "score", limitToLast = LEADERBOARD_SIZE }), "completed")
	if response.error:
		return null
	var result = []
	if !response.data:
		return result
	for user_id in response.data:
		var item = response.data[user_id]
		if !'score' in item:
			continue
		item.user_id = user_id
		item.is_player = user_id == score_data.user_id
		result.append(item)
	result.sort_custom(self, '_sort_by_score')
	return result


func test_send_score():
	var high_score_data = Global.get_persited_high_score_data()
	if !high_score_data:
		return
	var payload = { 
		just_cuz_of_vrs = calculate_fingerprint(high_score_data.score),
		user_name = score_data.user_name, 
		score = high_score_data.score, 
		map_id = high_score_data.map_id,
		os_name = OS.get_name(),
	}
	var path = "scoreboard_v2/%s" % [score_data.user_id]
	var result = yield(update_document(path, payload), "completed")
	printt("test_send_score", JSON.print({path = path, result = result, payload = payload}, "\t"))


# {
# 	"rules": {
# 		".write": false,
# 		"scoreboard_v2": {
# 			".indexOn": "score",
# 			".read": "auth !== null",
# 			"$uid": {
#             ".validate": "newData.hasChildren(['just_cuz_of_vrs', 'score', 'user_name', 'map_id', 'os_name']) && newData.child('just_cuz_of_vrs').isString() && newData.child('just_cuz_of_vrs').val().length < 100 && newData.child('user_name').isString() && newData.child('user_name').val().length < 100 && newData.child('score').isNumber() && newData.child('map_id').isString() && newData.child('map_id').val().length < 100 && newData.child('os_name').isString() && newData.child('os_name').val().length < 100",
# 			  ".write": "$uid === auth.uid && (!newData.child('score').exists() || (('' + (newData.child('score').val() + 234521))).replace('0', 'x').replace('1', 'm').replace('2', 'd').replace('3', 'c').replace('4', 'j').replace('5', 'w').replace('6', 'v').replace('7', 'z').replace('8', 'g').replace('9', 'y') == newData.child('just_cuz_of_vrs').val() )",
# 			  ".indexOn": "score"
# 			}
# 		}
# 	}
# }
func calculate_fingerprint(score):
	var magic_number = 234521
	var result = str(score + magic_number).replace('0', 'x').replace('1', 'm').replace('2', 'd').replace('3', 'c').replace('4', 'j').replace('5', 'w').replace('6', 'v').replace('7', 'z').replace('8', 'g').replace('9', 'y')
	return result


func update_score():
	if !score_data.user_name || !score_data.user_id:
		return null
	var high_score_data = Global.get_persited_high_score_data()
	if !high_score_data:
		return null
	if high_score_data.score <= 0:
		return null
	if score_data.last_score_sended >= high_score_data.score:
		return null
	# current score is less then last leaderboard
	if score_data.leaderboard.size() >= LEADERBOARD_SIZE:
		if high_score_data.score <= FP.safe_get(score_data.leaderboard[-1], 'score', 0):
			score_data.last_score_sended = high_score_data.score
			Persistent.save_data()
			return null
	var valid_token = yield(update_token(), "completed")
	if !valid_token:
		return null
	var payload = { 
		just_cuz_of_vrs = calculate_fingerprint(high_score_data.score),
		user_name = score_data.user_name, 
		score = high_score_data.score, 
		payload = to_json(high_score_data.payload),
		os_name = OS.get_name(),
	}
	var path = "scoreboard_v2/%s" % [score_data.user_id]
	printt("update_score: path", path)
	printt("update_score: payload", payload)
	var result = yield(update_document(path, payload), "completed")
	printt("update result", JSON.print(result, "\t"))
	if !FP.safe_get(result, 'error'):
		score_data.last_score_sended = high_score_data.score
		Persistent.save_data()
	return result


func update_user_name(name: String):
	var best_score_data = Global.get_persited_high_score_data()
	var result = null
	var name_changed = name != score_data.user_name
	# dont have score yet
	if !best_score_data:
		score_data.user_name = name
		Persistent.save_data()
		emit_signal("leaderboard_changed")
		yield(get_tree(), 'idle_frame')
		return null
	# full score update
	if best_score_data.score > score_data.last_score_sended:
		score_data.user_name = name
		result = sync_score()
		# not send sync request, just set persisted data
		if !result:
			score_data.user_name = name
			Persistent.save_data()
			emit_signal("leaderboard_changed")
			yield(get_tree(), 'idle_frame')
			return null

	# just update user name
	if !result && name_changed:
		var payload = { user_name = name }
		var path = "scoreboard_v2/%s" % [score_data.user_id]
		result = yield(update_document(path, payload), "completed")
		if !FP.safe_get(result, 'error'):
			score_data.user_name = name
			Persistent.save_data()
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	else:
		yield(get_tree(), 'idle_frame')
	emit_signal("leaderboard_changed")
	return result


func login_or_sign_up():
	if !score_data.user_id:
		score_data.user_email = '%s@gmail.com' % [FP.uuid_v4()]
		score_data.user_password = '%s' % [FP.uuid_v4()]
		var sign_up_response = yield(sign_up(score_data.user_email, score_data.user_password), "completed")
		if sign_up_response.error:
			return null
		score_data.user_id = sign_up_response.data.localId
		Persistent.save_data()
		if sign_up_response.error:
			return null
		return sign_up_response
	return yield(login(score_data.user_email, score_data.user_password), 'completed')


func login(email, password):
	var body := { 
		email =  email,
		password = password,
		returnSecureToken = true,
	}
	var request = _request({
		url = SIGN_IN_URL % api_key,
		method = 'post',
		body = body,
	})
	return yield(request, "completed")


func sign_up(email, password):
	var body := { 
		email = email,
		password = password,
		returnSecureToken = true,
	}
	var request = _request({
		url = SIGN_UP_URL % api_key,
		method = 'post',
		body = body,
	})
	return yield(request, "completed")


func save_document(path: String, data):
	return _request({
		url = _create_url(path),
		method = 'put',
		body = data,
	})


func get_document(path: String, options = {}) :
	return _request({ url = _create_url(path, options), })


func update_document(path: String, data):
	return _request({
		url = _create_url(path),
		method = 'patch',
		body = data,
	})


func delete_document(path: String):
	return _request({
		url = _create_url(path),
		method = 'delete',
	})


func _request(payload: Dictionary):
	var url = FP.safe_get(payload, 'url', null)
	var headers = FP.safe_get(payload, 'headers', [])
	var method = FP.safe_get(payload, 'method', 'get')
	var body = FP.safe_get(payload, 'body', "")
	var http = HTTPRequest.new()

	if typeof(body) != TYPE_STRING:
		body = to_json(body)

	method = method.to_upper()
	match method:
		'GET': method = HTTPClient.METHOD_GET
		'POST': method = HTTPClient.METHOD_POST
		'PUT': method = HTTPClient.METHOD_PUT
		'PATCH': method = HTTPClient.METHOD_PATCH
		'DELETE': method = HTTPClient.METHOD_DELETE

	add_child(http)

	http.request(url, headers, false, method, body)
	var result =  yield(http, "request_completed") as Array
	var error = null
	var data = null
	if result[1] >= 400:
		error = result[1]
	else:
		if FP.safe_get(payload, 'raw', false):
			data = result[3].get_string_from_ascii()
		else:
			var result_parsed := JSON.parse(result[3].get_string_from_ascii())
			data = result_parsed.result
			if result_parsed.error != OK:
				error = 'json parse error'
	http.queue_free()
	return {
		error = error,
		data = data,
	}


func _create_query_params(options = {}):
	var params = PoolStringArray(['auth=%s' % [score_data.token]])
	for key in options.keys():
		var value = options[key]
		if typeof(value) == TYPE_STRING:
			params.append('%s="%s"' % [key, value])
		else:
			params.append('%s=%s' % [key, value])
	return params.join('&')


func _create_url(path, options = {}):
	var queryParams = _create_query_params(options)
	return "%s%s.json?%s" % [firebase_url, path, queryParams]


func _sort_by_score(a, b):
	if !'score' in a || !'score' in b:
		return false
	return a.score > b.score


func _leaderboard_changed(response):
	if response.size() != leaderboard.size():
		return true
	for index in response.size():
		if response[index].score != leaderboard[index].score:
			return true
	return false


func _on_platform_user_name_changed(user_name):
	if user_name && !score_data.user_name:
		score_data.user_name = user_name
		Persistent.save_data()
		emit_signal("leaderboard_changed")



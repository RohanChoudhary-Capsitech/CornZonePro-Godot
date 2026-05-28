extends Node
 
const PROJECT_ID = "cornzonepro"
const CONFIG_URL = "https://firestore.googleapis.com/v1/projects/" + "cornzonepro" + "/databases/(default)/documents/config/game_settings"
 
signal config_loaded
 
var config := {}
var is_loaded := false
 
func _ready():
	fetch_config()
	# ✅ Re-fetch every 30 seconds
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 86400.0
	timer.autostart = true
	timer.timeout.connect(fetch_config)
	timer.start()
 
func fetch_config():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_config_received.bind(http))
	http.request(CONFIG_URL)
 
func _on_config_received(result, response_code, headers, body, http):
	http.queue_free()
	if response_code != 200:
		print("RemoteConfig: Failed to fetch, using defaults")
		_use_defaults()
		return
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	var fields = data.get("fields", {})
	config = _parse_fields(fields)
	is_loaded = true
	print("RemoteConfig loaded: ", config)
	emit_signal("config_loaded")  # ✅ fires every refresh
 
func _parse_fields(fields: Dictionary) -> Dictionary:
	var result = {}
	for key in fields:
		var val = fields[key]
		if val.has("booleanValue"):
			result[key] = val["booleanValue"]
		elif val.has("stringValue"):
			result[key] = val["stringValue"]
		elif val.has("integerValue"):
			result[key] = int(val["integerValue"])
		elif val.has("mapValue"):
			result[key] = _parse_fields(val["mapValue"]["fields"])
	return result
 
func get_bool(key: String, default := false) -> bool:
	return config.get(key, default)
 
func get_string(key: String, default := "") -> String:
	return config.get(key, default)
 
func _use_defaults():
	config = {
		"events": {
			"halloween_event": false,
			"daily_bonus": true
		}
	}
	is_loaded = true
	emit_signal("config_loaded")  # ✅ notify even on failure

extends Node

const PATH := "user://prefs.save"
const SAVE_DELAY := 2.0

var _data: Dictionary = {}
var _dirty := false
var _timer := 0.0

# --------------------
# INIT
# --------------------
func _ready():
	_load()

func _process(delta):
	if _dirty:
		_timer += delta
		if _timer >= SAVE_DELAY:
			save()

# --------------------
# CORE API
# --------------------
func set_value(key: String, value) -> void:
	_data[key] = value
	_dirty = true

func get_value(key: String, default_value = null):
	return _data.get(key, default_value)

func has_key(key: String) -> bool:
	return _data.has(key)

func delete_key(key: String) -> void:
	if _data.erase(key):
		_dirty = true

func clear_all():
	_data.clear()
	_dirty = true
	save()

func get_all_data() -> Dictionary:
	return _data.duplicate()

# --------------------
# TYPED HELPERS
# --------------------
func set_int(key: String, v: int): set_value(key, v)
func get_int(key: String, d := 0) -> int: return int(get_value(key, d))

func set_float(key: String, v: float): set_value(key, v)
func get_float(key: String, d := 0.0) -> float: return float(get_value(key, d))

func set_string(key: String, v: String): set_value(key, v)
func get_string(key: String, d := "") -> String: return str(get_value(key, d))

func set_bool(key: String, v: bool): set_value(key, v)
func get_bool(key: String, d := false) -> bool: return bool(get_value(key, d))

# --------------------
# SAVE / LOAD
# --------------------
func save() -> void:
	var file = FileAccess.open(PATH, FileAccess.WRITE)
	if file:
		var encoded = _encode(_data)
		file.store_string(JSON.stringify(encoded))
		_dirty = false
		_timer = 0.0

func _load() -> void:
	if FileAccess.file_exists(PATH):
		var file = FileAccess.open(PATH, FileAccess.READ)
		var parsed = JSON.parse_string(file.get_as_text())

		if typeof(parsed) == TYPE_DICTIONARY:
			_data = _decode(parsed)
		else:
			_data = {}

# --------------------
# SERIALIZATION
# --------------------
func _encode(value):
	if typeof(value) == TYPE_DICTIONARY:
		var result = {}
		for k in value.keys():
			result[k] = _encode(value[k])
		return result

	elif typeof(value) == TYPE_ARRAY:
		return value.map(_encode)

	elif value is Vector2:
		return {"__type": "Vector2", "x": value.x, "y": value.y}

	elif value is Vector3:
		return {"__type": "Vector3", "x": value.x, "y": value.y, "z": value.z}

	return value


func _decode(value):
	if typeof(value) == TYPE_DICTIONARY:
		if value.has("__type"):
			match value["__type"]:
				"Vector2":
					return Vector2(value["x"], value["y"])
				"Vector3":
					return Vector3(value["x"], value["y"], value["z"])

		var result = {}
		for k in value.keys():
			result[k] = _decode(value[k])
		return result

	elif typeof(value) == TYPE_ARRAY:
		return value.map(_decode)

	return value

# --------------------
# FORCE SAVE ON EXIT
# --------------------
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save()

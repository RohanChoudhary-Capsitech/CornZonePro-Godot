@tool
extends EditorScript

const OUTPUT_PATH := "res://Data/offline_catalog.json"

const SCAN_ROOTS := [
	"res://Resources/Bags",
	 "res://Resources/Boards",
	# "res://Data/Skins",
	# "res://Scripts/Resource",
]

const BAG_TYPE := "Cornbags"
const BOARD_TYPE := "Boards"
const INTERNAL_PROPERTY_PREFIXES := ["resource_", "script"]

var _items_by_id: Dictionary = {}
var _scanned_files: int = 0
var _skipped_files: int = 0

func _run() -> void:
	_items_by_id.clear()
	_scanned_files = 0
	_skipped_files = 0

	print("Generating offline catalog...")

	for root in SCAN_ROOTS:
		if DirAccess.dir_exists_absolute(root):
			print("Scanning: %s" % root)
			_scan_dir(root)
		else:
			print("Missing scan folder: %s" % root)

	var items := _items_by_id.values()
	items.sort_custom(func(a, b): return str(a.get("itemId", "")) < str(b.get("itemId", "")))

	if items.is_empty():
		push_warning("No catalog items found. Scanned %s resource files, skipped %s. Keeping existing %s unchanged." % [_scanned_files, _skipped_files, OUTPUT_PATH])
		return

	var data := {
		"items": items
	}

	_write_json(data)
	print("Offline catalog generated: %s items from %s resource files, skipped %s -> %s" % [items.size(), _scanned_files, _skipped_files, OUTPUT_PATH])

func _scan_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue

		var full_path := path.path_join(file_name)
		if dir.current_is_dir():
			_scan_dir(full_path)
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			_read_resource(full_path)

		file_name = dir.get_next()
	dir.list_dir_end()

func _read_resource(path: String) -> void:
	var resource := ResourceLoader.load(path)
	if resource == null:
		_skipped_files += 1
		print("Skipped unreadable resource: %s" % path)
		return

	_scanned_files += 1

	if _has_property(resource, "bag_skins"):
		for entry in _as_array(resource.get("bag_skins")):
			_add_resource_item(entry, path, BAG_TYPE)

	if _has_property(resource, "board_skins"):
		for entry in _as_array(resource.get("board_skins")):
			_add_resource_item(entry, path, BOARD_TYPE)

	if not _has_property(resource, "bag_skins") and not _has_property(resource, "board_skins"):
		_add_resource_item(resource, path, "")

func _add_resource_item(resource: Variant, source_path: String, forced_type: String) -> void:
	if resource == null:
		return

	var item_id := str(_first_value(resource, ["itemId", "item_id", "skin_id", "id"], ""))
	if item_id.strip_edges() == "":
		item_id = source_path.get_file().get_basename()

	var item_type := forced_type
	if item_type == "":
		item_type = str(_first_value(resource, ["type", "skin_type", "item_type", "category"], ""))
	if item_type == "":
		item_type = _infer_type_from_path(source_path)
	if item_type == "":
		_skipped_files += 1
		print("Skipped resource with unknown type: %s" % source_path)
		return

	var display_name := str(_first_value(resource, ["displayName", "display_name", "name", "title"], ""))
	if display_name == "":
		display_name = _title_from_id(item_id)

	var price := int(_first_value(resource, ["price", "cost", "coins"], 0))
	var unlocked := bool(_first_value(resource, ["unlocked", "is_unlocked", "default_unlocked"], price == 0))

	var item := _export_resource_data(resource)
	item.merge({
		"itemId": item_id,
		"displayName": display_name,
		"price": price,
		"type": item_type,
		"unlocked": unlocked
	}, true)

	_items_by_id[item_id] = item

func _first_value(resource: Variant, names: Array, fallback: Variant) -> Variant:
	for property_name in names:
		if _has_property(resource, property_name):
			var value = resource.get(property_name)
			if value != null:
				return value
	return fallback

func _has_property(resource: Variant, property_name: String) -> bool:
	if not (resource is Object):
		return false

	for property in resource.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false

func _as_array(value: Variant) -> Array:
	if value is Array:
		return value
	return []

func _export_resource_data(resource: Variant) -> Dictionary:
	var data := {}
	if not (resource is Object):
		return data

	for property in resource.get_property_list():
		var property_name := str(property.get("name", ""))
		if property_name == "":
			continue
		if _is_internal_property(property_name):
			continue

		var value = resource.get(property_name)
		var serializable_value = _to_json_value(value)
		if serializable_value != null:
			data[property_name] = serializable_value

	return data

func _is_internal_property(property_name: String) -> bool:
	if property_name.begins_with("_"):
		return true

	for prefix in INTERNAL_PROPERTY_PREFIXES:
		if property_name.begins_with(prefix):
			return true

	return false

func _to_json_value(value: Variant) -> Variant:
	var value_type := typeof(value)

	match value_type:
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return value

		TYPE_STRING_NAME, TYPE_NODE_PATH:
			return str(value)

		TYPE_VECTOR2, TYPE_VECTOR2I:
			return {
				"x": value.x,
				"y": value.y
			}

		TYPE_VECTOR3, TYPE_VECTOR3I:
			return {
				"x": value.x,
				"y": value.y,
				"z": value.z
			}

		TYPE_VECTOR4, TYPE_VECTOR4I, TYPE_QUATERNION:
			return {
				"x": value.x,
				"y": value.y,
				"z": value.z,
				"w": value.w
			}

		TYPE_COLOR:
			return value.to_html(true)

		TYPE_RECT2, TYPE_RECT2I:
			return {
				"position": _to_json_value(value.position),
				"size": _to_json_value(value.size)
			}

		TYPE_ARRAY:
			var array := []
			for entry in value:
				var json_entry = _to_json_value(entry)
				if json_entry != null:
					array.append(json_entry)
			return array

		TYPE_DICTIONARY:
			var dictionary := {}
			for key in value.keys():
				var json_value = _to_json_value(value[key])
				if json_value != null:
					dictionary[str(key)] = json_value
			return dictionary

		TYPE_OBJECT:
			if value is Resource:
				if value.resource_path != "":
					return value.resource_path
				return _export_resource_data(value)
			return null

		TYPE_TRANSFORM2D, TYPE_TRANSFORM3D, TYPE_PLANE, TYPE_PROJECTION, TYPE_AABB, TYPE_BASIS, TYPE_RID, TYPE_CALLABLE, TYPE_SIGNAL:
			return null

		_:
			return null

func _infer_type_from_path(path: String) -> String:
	var lower_path := path.to_lower()

	if lower_path.contains("board"):
		return BOARD_TYPE

	if lower_path.contains("bag") or lower_path.contains("cornbag") or lower_path.contains("sandbag"):
		return BAG_TYPE

	return ""

func _title_from_id(item_id: String) -> String:
	var words := item_id.replace("-", "_").split("_", false)

	for i in range(words.size()):
		words[i] = str(words[i]).capitalize()

	return " ".join(words)

func _write_json(data: Dictionary) -> void:
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not write %s" % OUTPUT_PATH)
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()

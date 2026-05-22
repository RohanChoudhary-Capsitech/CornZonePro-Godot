extends Node
signal catalog_loaded

const LOCAL_CATALOG_PATH = "res://Data/offline_catalog.json"

var _catalog: Dictionary = {}
var _loaded: bool = false

func load_catalog():
	if _loaded:
		emit_signal("catalog_loaded")
		return
	_load_local_catalog()

func load_offline_catalog():
	_load_local_catalog()

func _load_local_catalog():
	if not FileAccess.file_exists(LOCAL_CATALOG_PATH):
		emit_signal("catalog_loaded")
		return
	var file = FileAccess.open(LOCAL_CATALOG_PATH, FileAccess.READ)
	if not file:
		emit_signal("catalog_loaded")
		return
	var result = JSON.parse_string(file.get_as_text())
	# print("RESULTTTTTTTTTTTTTTTTTTTTTTT: ",result)
	file.close()
	if result and result.has("items"):
		for item in result["items"]:
			if item.has("itemId"):
				_catalog[item["itemId"]] = item
	_loaded = true
	emit_signal("catalog_loaded")

func get_item_price(item_id: String, fallback: int = 0) -> int:
	if _catalog.has(item_id):
		return int(_catalog[item_id].get("price", fallback))
	return fallback

func get_item_name(item_id: String, fallback: String = "Unknown") -> String:
	if _catalog.has(item_id):
		return str(_catalog[item_id].get("displayName", fallback))
	return fallback

func get_item_type(item_id: String) -> String:
	if _catalog.has(item_id):
		return str(_catalog[item_id].get("type", ""))
	return ""

func is_loaded() -> bool:
	return _loaded
	
func get_item_icon(item_id: String, fallback: String = "") -> String:
	if _catalog.has(item_id):
		return str(_catalog[item_id].get("icon", fallback))
	return fallback	

func get_material(item_id: String, fallback: String = "") -> String:
	if _catalog.has(item_id):
		return str(_catalog[item_id].get("material_override", fallback))
	return fallback	


func has_item(item_id: String) -> bool:
	return _catalog.has(item_id)

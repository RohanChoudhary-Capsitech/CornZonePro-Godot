extends VBoxContainer
@export var green_signal: Texture2D
@export var white_signal: Texture2D

@export var bag_data_scene: PackedScene

const CATALOG_PATH = "res://Data/offline_catalog.json"

func _ready() -> void:
	if not FirebaseManager.on_data_loaded.is_connected(load_bag_data):
		FirebaseManager.on_data_loaded.connect(load_bag_data)
	if not PlayerData.has_loaded_data:
		PlayerData.load_local()
	load_bag_data()

func load_bag_data():
	for child in get_children():
		child.queue_free()

	if not FileAccess.file_exists(CATALOG_PATH):
		push_error("Catalog not found: " + CATALOG_PATH)
		return

	var file = FileAccess.open(CATALOG_PATH, FileAccess.READ)
	var result = JSON.parse_string(file.get_as_text())
	file.close()

	if not result or not result.has("items"):
		push_error("Invalid catalog format")
		return

	for item in result["items"]:
		if item.get("type", "") != "Cornbags":
			continue

		# Inject ownership state from PlayerData
		var item_id = item.get("itemId", "")
		item["bought"] = item_id in PlayerData.bags_owned
		item["unlocked"] = item["bought"]
		item["equipped"] = item_id == PlayerData.equipped_cornbag

		if bag_data_scene:
			var instance = bag_data_scene.instantiate()
			add_child(instance)
			instance.setup(item, green_signal, white_signal)

extends CanvasLayer

var map_time:float
var map_entries: Array = []


#region Map_constants
#----Scenes---------------------------------
const lawn:="res://Scenes/Maps/lawn.tscn"
const street:="res://Scenes/Maps/street.tscn"
const rooftop:="res://Scenes/Maps/rooftop.tscn"
const backyard:="res://Scenes/Maps/backyard.tscn"
const metro:="res://Scenes/Maps/metro.tscn"
const stadium:="res://Scenes/Maps/stadium.tscn"
#-----------------------------------------------

#----Map Configs-----------------------------
const lawn_config:=preload("res://Resources/Maps/lawn.tres")
const street_config:=preload("res://Resources/Maps/street.tres")
const rooftop_config:=preload("res://Resources/Maps/rooftop.tres")
const backyard_config:=preload("res://Resources/Maps/backyard.tres")
const metro_config:=preload("res://Resources/Maps/metro.tres")
const stadium_config:=preload("res://Resources/Maps/stadium.tres")
#-----------------------------------------------

#endregion

@onready var lawn_button: Button = $Panel/ScrollContainer/HBoxContainer/LawnMap
@onready var street_button: Button = $Panel/ScrollContainer/HBoxContainer/StreetMap
@onready var stadium_button: Button = $Panel/ScrollContainer/HBoxContainer/StadiumMap
@onready var backyard_button: Button = $Panel/ScrollContainer/HBoxContainer/BackyardMap
@onready var rooftop_button: Button = $Panel/ScrollContainer/HBoxContainer/RooftopMap
@onready var metro_button: Button = $Panel/ScrollContainer/HBoxContainer/MetroMap

const OVERLAY_COLOR := Color(0.0, 0.0, 0.0, 0.72)


func _ready() -> void:
	map_entries = [
		{
			"button": lawn_button,
			"scene_path": lawn,
			"config": lawn_config,
			"overlay": $Panel/ScrollContainer/HBoxContainer/LawnMap/Overlay,
			"status_label": $Panel/ScrollContainer/HBoxContainer/LawnMap/Overlay/StatusLabel,
			"price_text": $Panel/ScrollContainer/HBoxContainer/LawnMap/Overlay/TextureRect/Price,
			"unlock_button": $Panel/ScrollContainer/HBoxContainer/LawnMap/Overlay/UnlockButton
		},
		{
			"button": street_button,
			"scene_path": street,
			"config": street_config,
			"overlay": $Panel/ScrollContainer/HBoxContainer/StreetMap/Overlay,
			"status_label": $Panel/ScrollContainer/HBoxContainer/StreetMap/Overlay/StatusLabel,
			"price_text": $Panel/ScrollContainer/HBoxContainer/StreetMap/Overlay/TextureRect/Price,
			"unlock_button": $Panel/ScrollContainer/HBoxContainer/StreetMap/Overlay/UnlockButton
		},
		{
			"button": stadium_button,
			"scene_path": stadium,
			"config": stadium_config,
			"overlay": $Panel/ScrollContainer/HBoxContainer/StadiumMap/Overlay,
			"status_label": $Panel/ScrollContainer/HBoxContainer/StadiumMap/Overlay/StatusLabel,
			"price_text": $Panel/ScrollContainer/HBoxContainer/StadiumMap/Overlay/TextureRect/Price,
			"unlock_button": $Panel/ScrollContainer/HBoxContainer/StadiumMap/Overlay/UnlockButton
		},
		{
			"button": backyard_button,
			"scene_path": backyard,
			"config": backyard_config,
			"overlay": $Panel/ScrollContainer/HBoxContainer/BackyardMap/Overlay,
			"status_label": $Panel/ScrollContainer/HBoxContainer/BackyardMap/Overlay/StatusLabel,
			"price_text": $Panel/ScrollContainer/HBoxContainer/BackyardMap/Overlay/TextureRect/Price,
			"unlock_button": $Panel/ScrollContainer/HBoxContainer/BackyardMap/Overlay/UnlockButton
		},
		{
			"button": rooftop_button,
			"scene_path": rooftop,
			"config": rooftop_config,
			"overlay": $Panel/ScrollContainer/HBoxContainer/RooftopMap/Overlay,
			"status_label": $Panel/ScrollContainer/HBoxContainer/RooftopMap/Overlay/StatusLabel,
			"price_text": $Panel/ScrollContainer/HBoxContainer/RooftopMap/Overlay/TextureRect/Price,
			"unlock_button": $Panel/ScrollContainer/HBoxContainer/RooftopMap/Overlay/UnlockButton
		},
		{
			"button": metro_button,
			"scene_path": metro,
			"config": metro_config,
			"overlay": $Panel/ScrollContainer/HBoxContainer/MetroMap/Overlay,
			"status_label": $Panel/ScrollContainer/HBoxContainer/MetroMap/Overlay/StatusLabel,
			"price_text": $Panel/ScrollContainer/HBoxContainer/MetroMap/Overlay/TextureRect/Price,
			"unlock_button": $Panel/ScrollContainer/HBoxContainer/MetroMap/Overlay/UnlockButton
		}
	]

	for entry in map_entries:
		var unlock_button = entry["unlock_button"]
		var config = entry["config"]

		unlock_button.pressed.connect(_on_unlock_button_pressed.bind(config))

	visibility_changed.connect(_on_visibility_changed)
	refresh_map_locks()


func _on_visibility_changed() -> void:
	if visible:
		refresh_map_locks()

func game_setup()->void:
	UIManager._begin_match(GameSession.selected_mode,
	GameSession.selected_map_path,GameSession.required_ui,map_time)


func refresh_map_locks() -> void:
	if map_entries.is_empty():
		return

	for entry in map_entries:
		var button: Button = entry["button"]
		var config: MapConfig = entry["config"]
		
		var overlay: Control = entry["overlay"]
		var status_label: Label = entry["status_label"]
		var price_label: Label = entry["price_text"]
		var unlock_button: Button = entry["unlock_button"]
		
		var is_available := _is_map_available(config)
		var is_locked := _is_map_locked(config)

		overlay.visible = not is_available
		button.tooltip_text = _get_map_tooltip(config)

		if is_available:
			continue

		status_label.text = config.get_unavailable_reason(GameSession.selected_mode)
		price_label.visible = is_locked
		unlock_button.visible = is_locked

		if is_locked:
			price_label.text = "Price: %d" % config.get_price_for_mode(GameSession.selected_mode)
		else:
			price_label.text = ""


func _is_map_available(config: MapConfig) -> bool:
	if config == null:
		return false

	return config.is_available_for_mode(GameSession.selected_mode)


func _is_map_locked(config: MapConfig) -> bool:
	if config == null:
		return false

	return config.supports_mode(GameSession.selected_mode) and not config.is_unlocked_for_mode(GameSession.selected_mode)


func _get_map_tooltip(config: MapConfig) -> String:
	if config == null:
		return "Map data is missing."

	if _is_map_available(config):
		return "%s is ready to play in %s mode." % [config.map_name, GameSession.selected_mode]

	return config.get_unavailable_reason(GameSession.selected_mode)


func _on_unlock_button_pressed(config: MapConfig) -> void:
	SoundManager.play_button_clicks()

	if config == null:
		return

	var price := config.get_price_for_mode(GameSession.selected_mode)
	var coins := int(PlayerData.coins)

	if price > coins:
		AnimateManager.show_notification($Notification, "Not enough coins to unlock", 1.5)
		push_warning("[MapSelect] Not enough coins to unlock %s for %s." % [config.map_name, GameSession.selected_mode])
		return

	#Prefs.set_int("coins", coins - price)
	DataManager.spend_coins(price)
	config.set_unlocked_for_mode(GameSession.selected_mode, true)
	_update_coin_labels()
	refresh_map_locks()


func _update_coin_labels() -> void:
	var coin_text := get_node_or_null("../HomeScreen/Panel/TopPanel/Coin/CoinText") as Label
	if coin_text != null:
		coin_text.text = str(PlayerData.coins)

	var inventory_coin_text := get_node_or_null("../InventoryScreen/Panel/TopPanel/Coin/CoinText") as Label
	if inventory_coin_text != null:
		inventory_coin_text.text = str(PlayerData.coins)


func _select_map(scene_path: String, config: MapConfig) -> void:
	SoundManager.play_button_clicks()

	if config == null or not config.is_available_for_mode(GameSession.selected_mode):
		var reason := "This map is locked."
		if config != null:
			reason = config.get_unavailable_reason(GameSession.selected_mode)
		push_warning("[MapSelect] " + reason)
		refresh_map_locks()
		return

	GameSession.selected_map_path = scene_path
	map_time = config.time_limit
	game_setup()

func _on_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")


#region Map_Button_Functions

func _on_lawn_map_pressed() -> void:
	_select_map(lawn, lawn_config)

func _on_street_map_pressed() -> void:
	_select_map(street, street_config)

func _on_stadium_map_pressed() -> void:
	_select_map(stadium, stadium_config)

func _on_backyard_map_pressed() -> void:
	_select_map(backyard, backyard_config)

func _on_rooftop_map_pressed() -> void:
	_select_map(rooftop, rooftop_config)

func _on_metro_map_pressed() -> void:
	_select_map(metro, metro_config)
#endregion

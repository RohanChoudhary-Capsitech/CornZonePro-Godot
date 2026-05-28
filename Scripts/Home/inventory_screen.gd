extends CanvasLayer

@onready var content = $Panel/BottomContent/TextureRect/ScrollContainer/Content
@onready var preview = $Panel/PreviewArea
@onready var username:Label = $Panel/Profile/Label
@onready var coin:Label = $Panel/TopPanel/Coin/CoinText

func _ready() -> void:
	if not FirebaseManager.on_data_loaded.is_connected(update_ui):
		FirebaseManager.on_data_loaded.connect(update_ui)
	if FirebaseManager.data_loaded or PlayerData.has_loaded_data:
		await update_ui()
	else:
		pass
	content.item_selected.connect(_on_item_selected)

func _on_item_selected(material):
	preview.set_item_material(material)

func _on_shop_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas_with_transition($"../ShopScreen")
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()

func update_ui() -> void:
	username.text = str(PlayerData.player_name)
	coin.text = str(PlayerData.coins)
 
func refresh_from_local() -> void:
	PlayerData.load_local()
	update_ui()
	if content and content.has_method("refresh_from_local"):
		content.refresh_from_local()
 
 
func _on_play_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas_with_transition($"../HomeScreen")
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()


func _on_lock_button_1_st_pressed() -> void:
	AnimateManager.show_notification($Notification, "New Features will coming soon", 1.5)


func _on_lock_button_2_nd_pressed() -> void:
	AnimateManager.show_notification($Notification, "New Features will coming soon", 1.5)

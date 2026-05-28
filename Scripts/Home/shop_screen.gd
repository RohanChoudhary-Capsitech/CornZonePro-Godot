extends CanvasLayer
const BAG_DATA = preload("uid://dkxtmd1so4k4r")


func _ready() -> void:
	AdManager.show_banner()
	AnimateManager.notify.connect(_notify)


func _notify():
	AnimateManager.show_notification($Notification,"Not enough coins", 1.5)

func _on_play_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas_with_transition($"../HomeScreen")
	#AdManager.show_banner()
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()


func _on_inventory_button_pressed() -> void:
	SoundManager.play_button_clicks()
	AdManager.show_banner()
	var inventory_screen := $"../InventoryScreen"
	if inventory_screen.has_method("refresh_from_local"):
		inventory_screen.refresh_from_local()
	UIManager.enable_canvas_with_transition(inventory_screen)
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()


func _on_bag_buy_button_pressed() -> void:
	SoundManager.play_button_clicks()
	PlayerData.load_local()
	$Panel/BagsPanel/ScrollContainer/BagDataContent.load_bag_data()
	await TransitionLayer.fade_out()
	$Panel/MidPanel.visible = false
	$Panel/BagsPanel.visible = true
	await TransitionLayer.fade_in()


func _on_bag_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	await TransitionLayer.fade_out()
	$Panel/BagsPanel.visible = false
	$Panel/MidPanel.visible = true
	await TransitionLayer.fade_in()
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()
 
 
func _on_board_buy_button_pressed() -> void:
	SoundManager.play_button_clicks()
	PlayerData.load_local()
	$Panel/BoardsPanel/ScrollContainer/BoardDataContent.load_board_data()
	await TransitionLayer.fade_out()
	$Panel/MidPanel.visible = false
	$Panel/BoardsPanel.visible = true
	await TransitionLayer.fade_in()


func _on_board_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	await TransitionLayer.fade_out()
	$Panel/BoardsPanel.visible = false
	$Panel/MidPanel.visible = true
	await TransitionLayer.fade_in()
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()

 


func _on_lock_button_1_st_pressed() -> void:
	AnimateManager.show_notification($Notification, "New Features will coming soon", 1.5)


func _on_lock_button_2_nd_pressed() -> void:
	AnimateManager.show_notification($Notification, "New Features will coming soon", 1.5)

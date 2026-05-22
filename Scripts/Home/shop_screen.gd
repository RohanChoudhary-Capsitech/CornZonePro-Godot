extends CanvasLayer

func _ready() -> void:
	AdManager.show_banner()

func _on_play_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas($"../HomeScreen")
	#AdManager.show_banner()
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()


func _on_inventory_button_pressed() -> void:
	SoundManager.play_button_clicks()
	AdManager.show_banner()
	var inventory_screen := $"../InventoryScreen"
	if inventory_screen.has_method("refresh_from_local"):
		inventory_screen.refresh_from_local()
	UIManager.enable_canvas(inventory_screen)
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()


func _on_bag_buy_button_pressed() -> void:
	SoundManager.play_button_clicks()
	PlayerData.load_local()
	$Panel/BagsPanel/ScrollContainer/BagDataContent.load_bag_data()
	$Panel/MidPanel.visible = false
	$Panel/BagsPanel.visible = true


func _on_bag_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/BagsPanel.visible = false
	$Panel/MidPanel.visible = true
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()
 
 
func _on_board_buy_button_pressed() -> void:
	SoundManager.play_button_clicks()
	PlayerData.load_local()
	$Panel/BoardsPanel/ScrollContainer/BoardDataContent.load_board_data()
	$Panel/MidPanel.visible = false
	$Panel/BoardsPanel.visible = true


func _on_board_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/BoardsPanel.visible = false
	$Panel/MidPanel.visible = true
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()

 

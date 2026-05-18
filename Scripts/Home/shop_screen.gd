extends CanvasLayer

func _ready() -> void:
	AdManager.show_banner()

func _on_play_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas($"../HomeScreen")
	AdManager.show_banner()


func _on_inventory_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas($"../InventoryScreen")
	AdManager.show_banner()


func _on_bag_buy_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/MidPanel.visible = false
	$Panel/BagsPanel.visible = true


func _on_bag_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/BagsPanel.visible = false
	$Panel/MidPanel.visible = true


func _on_board_buy_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/MidPanel.visible = false
	$Panel/BoardsPanel.visible = true


func _on_board_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/BoardsPanel.visible = false
	$Panel/MidPanel.visible = true

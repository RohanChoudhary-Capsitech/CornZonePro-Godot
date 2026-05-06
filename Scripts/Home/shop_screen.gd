extends CanvasLayer


func _on_play_button_pressed() -> void:
	UIManager.enable_canvas($"../HomeScreen")


func _on_inventory_button_pressed() -> void:
	UIManager.enable_canvas($"../InventoryScreen")


func _on_bag_buy_button_pressed() -> void:
	$Panel/MidPanel.visible = false
	$Panel/BagsPanel.visible = true


func _on_bag_cross_button_pressed() -> void:
	$Panel/BagsPanel.visible = false
	$Panel/MidPanel.visible = true


func _on_board_buy_button_pressed() -> void:
	$Panel/MidPanel.visible = false
	$Panel/BoardsPanel.visible = true


func _on_board_cross_button_pressed() -> void:
	$Panel/BoardsPanel.visible = false
	$Panel/MidPanel.visible = true

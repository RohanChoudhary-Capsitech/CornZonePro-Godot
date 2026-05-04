extends CanvasLayer


func _on_play_button_pressed() -> void:
	UIManager.enable_canvas($"../HomeScreen")


func _on_inventory_button_pressed() -> void:
	UIManager.enable_canvas($"../InventoryScreen")

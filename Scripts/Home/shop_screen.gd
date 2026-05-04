extends CanvasLayer


func _on_play_button_pressed() -> void:
	UIManager.toggle_canvas($".")


func _on_inventory_button_pressed() -> void:
	UIManager.toggle_canvas($"../InventoryScreen")

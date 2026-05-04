extends CanvasLayer


func _on_shop_button_pressed() -> void:
	UIManager.enable_canvas($"../ShopScreen")


func _on_play_button_pressed() -> void:
	UIManager.enable_canvas($"../HomeScreen")

extends CanvasLayer

func _ready() -> void:
	$Panel/TopPanel/Coin/CoinText.text = str(Prefs.get_int("coins"))

func _on_shop_button_pressed() -> void:
	UIManager.enable_canvas($"../ShopScreen")


func _on_play_button_pressed() -> void:
	UIManager.enable_canvas($"../HomeScreen")

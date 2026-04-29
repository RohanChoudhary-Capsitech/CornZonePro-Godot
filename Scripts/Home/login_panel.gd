extends CanvasLayer

func _on_submit_button_pressed() -> void:
	UIManager.enable_canvas($"../HomeScreen") 
	Prefs.set_int("user",1)

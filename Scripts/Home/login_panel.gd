extends CanvasLayer

func _on_submit_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas($"../HomeScreen")
	Prefs.set_int("user",1)

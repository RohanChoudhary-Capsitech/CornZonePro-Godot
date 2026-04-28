extends CanvasLayer

func _on_setting_button_pressed() -> void:
	UIManager.toggle_canvas($"../SettingScreen")

func _on_timer_button_pressed() -> void:
	UIManager.single_player()

func _on_lan_button_pressed() -> void:
	UIManager.local_multiplayer()

func _on_pass_n_play_button_pressed() -> void:
	UIManager.pass_play()

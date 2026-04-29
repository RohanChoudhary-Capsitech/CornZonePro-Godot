extends CanvasLayer

func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")


func _on_privacy_policy_button_pressed() -> void:
	OS.shell_open("https://www.thegamewise.com/privacy-policy/")

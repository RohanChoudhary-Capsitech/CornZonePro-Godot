extends CanvasLayer

func _on_no_pressed() -> void:
	UIManager.toggle_canvas(self)

func _on_yes_pressed() -> void:
	UIManager.home()

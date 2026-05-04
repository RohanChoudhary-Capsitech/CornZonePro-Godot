extends CanvasLayer



func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")


func _on_host_button_pressed() -> void:
	NetworkManager.host_game()


func _on_join_button_pressed() -> void:
	#NetworkManager.join_game()
	pass

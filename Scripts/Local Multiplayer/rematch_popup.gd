extends CanvasLayer

func _on_yes_pressed() -> void:
	SoundManager.play_button_clicks()
	if multiplayer and multiplayer.is_server():
		NetworkManager.accept_rematch()
	else:
		NetworkManager.accept_rematch.rpc_id(1)

func _on_no_pressed() -> void:
	SoundManager.play_button_clicks()
	$"../GameOver/Control/GameOver BG/Rematch".disabled=false
	NetworkManager.reject_rematch()
	visible = false
	if UIManager.result_screen:
		UIManager.enable_canvas(UIManager.result_screen)

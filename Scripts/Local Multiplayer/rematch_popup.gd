extends CanvasLayer

func _on_yes_pressed() -> void:
	if multiplayer and multiplayer.is_server():
		NetworkManager.accept_rematch()
	else:
		NetworkManager.accept_rematch.rpc_id(1)

func _on_no_pressed() -> void:
	$"../GameOver/Control/GameOver BG/Rematch".disabled=false
	UIManager.home()

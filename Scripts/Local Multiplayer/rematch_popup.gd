extends CanvasLayer

func _on_yes_pressed() -> void:
	NetworkManager.accept_rematch.rpc()

func _on_no_pressed() -> void:
	$"../GameOver/Control/GameOver BG/Rematch".disabled=false
	UIManager.home()

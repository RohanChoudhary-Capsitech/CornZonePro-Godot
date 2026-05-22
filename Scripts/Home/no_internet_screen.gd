extends CanvasLayer

var isInternetConnected : bool = false

func _on_button_pressed() -> void:
	isInternetConnected = await FirebaseManager.internet_available()
	if  isInternetConnected == true:
		hide()

extends TextureRect

@onready var icon = $"."
var link: String

func setup(data):
	icon.texture = data.icon
	link = data.link
	


func _on_button_pressed() -> void:
	SoundManager.play_button_clicks()
	OS.shell_open(link)

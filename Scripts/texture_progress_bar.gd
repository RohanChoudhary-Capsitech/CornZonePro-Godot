extends TextureProgressBar

func _ready():
	value = 0
	var tween = create_tween()
	tween.tween_property(self, "value", max_value, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_loading_finished)

func _on_loading_finished():
	print("Loading complete!")
	UIManager.disable_canvas($"../..")
	UIManager.enable_canvas($"../../../LoadingScreen2")

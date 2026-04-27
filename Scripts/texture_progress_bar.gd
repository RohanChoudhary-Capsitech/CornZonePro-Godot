extends TextureProgressBar

func _ready():
	value = 0
	var tween = create_tween()
	tween.tween_property(self, "value", max_value, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_loading_finished)

func _on_loading_finished():
	print("Loading complete!")
	var val=Prefs.get_int("user",0)
	if 1==val:
		UIManager.enable_canvas($"../../../HomeScreen")
	else:
		UIManager.enable_canvas($"../../../LoginScreen")
	#UIManager.enable_canvas()

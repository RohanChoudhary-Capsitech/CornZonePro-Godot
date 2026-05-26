extends CanvasLayer


var is_game_over := false
@onready var timer_slider := $"../InGame UI/Slider/TimerSlider" as MatchTimerSlider
@onready var coins_text := $"Control/PausePanel BG/CoinsText" as Label

func _ready() -> void:
	timer_slider.time_over.connect(gameover)

# func gameover()->void:
# 	print("game over")
# 	UIManager.enable_canvas($".")
# 	coins_text.text = str(DataManager.get_coins())

func gameover()->void:
	if is_game_over:
		return
	
	is_game_over = true
	
	timer_slider.time_over.disconnect(gameover)
	SoundManager.play_game_over()
	UIManager.enable_canvas($".")
	pop_animation($Control)
	coins_text.text = str(DataManager.get_coins())
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()
 

func _on_home_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.home()


func _on_share_pressed() -> void:
	print("share button pressed")
	if Engine.has_singleton("GodotShare"):
		var share: Object = Engine.get_singleton("GodotShare")
		share.shareText("Test from Godot")
	else:
		print("Plugin not found")


func _on_restart_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.restart()

func pop_animation(node: Control):
	node.scale = Vector2.ZERO
	node.pivot_offset = node.size / 2
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2(1.15, 1.15), 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

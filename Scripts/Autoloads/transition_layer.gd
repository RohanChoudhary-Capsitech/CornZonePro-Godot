extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready():
	# Start with the screen completely clear/transparent
	color_rect.modulate.a = 0.0
	color_rect.hide()

func change_scene(target_scene_path: String, fade_to_color: Color = Color.BLACK):
	# 1. Update the transition background color
	color_rect.color = fade_to_color
	color_rect.show()
	
	# 2. Fade IN (Screen goes from clear to solid color)
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(color_rect, "modulate:a", 1.0, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	await fade_in_tween.finished
	
	# 3. Swap the underlying game scenes while the screen is solid
	get_tree().change_scene_to_file(target_scene_path)
	
	# Wait one frame to ensure the new scene initializes fully
	await get_tree().process_frame
	
	# 4. Fade OUT (Screen goes from solid color back to transparent)
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(color_rect, "modulate:a", 0.0, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	await fade_out_tween.finished
	
	# 5. Hide the overlay completely to restore background processing optimization
	color_rect.hide()

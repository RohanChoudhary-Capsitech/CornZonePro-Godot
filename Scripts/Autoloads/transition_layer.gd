extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready():
	color_rect.modulate.a = 0.0
	color_rect.hide()
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Parda kaala karne ke liye
func fade_out():
	color_rect.show()
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(color_rect, "modulate:a", 1.0, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	await fade_in_tween.finished

# Parda wapas saaf karne ke liye
func fade_in():
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(color_rect, "modulate:a", 0.0, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	await fade_out_tween.finished
	color_rect.hide()

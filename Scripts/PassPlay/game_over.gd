extends CanvasLayer

@onready var winner_text: Label = $"Control/GameOver BG/Dash/Player Winner Declaration"
@onready var p1_score_text: Label = $"Control/GameOver BG/Dash/Player 1 Score"
@onready var p2_score_text: Label = $"Control/GameOver BG/Dash/Label"

func _ready() -> void:
	GameSession.turns_exhausted.connect(_update_results)

func _update_results() -> void:
	pop_animation($Control)
	var p1_score: int = GameSession.score_p1
	var p2_score: int = GameSession.score_p2

	p1_score_text.text = str(p1_score)
	p2_score_text.text = str(p2_score)

	if p1_score > p2_score:
		winner_text.text = "Player 1 Wins"
	elif p2_score > p1_score:
		winner_text.text = "Player 2 Wins"
	else:
		winner_text.text = "You have a tie"

func _on_home_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.home()

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

extends CanvasLayer

@onready var winner_text: Label = $"Control/GameOver BG/Dash/Player Winner Declaration"
@onready var p1_score_text: Label = $"Control/GameOver BG/Dash/Player 1 Score"
@onready var p2_score_text: Label = $"Control/GameOver BG/Dash/Label"

func _ready() -> void:
	GameSession.turns_exhausted.connect(_update_results)

func _score_key(base_key: String) -> String:
	if GameSession.selected_mode == "Local":
		return base_key
	return "passplay_" + base_key

func _update_results() -> void:
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
	UIManager.home()

func _on_restart_pressed() -> void:
	UIManager.restart()

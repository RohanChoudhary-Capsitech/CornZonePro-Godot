extends CanvasLayer

# Player 1 score labels
@onready var p1_scores = [
	$"ScoreBoard/Player 1 Scores/p1/1st score",
	$"ScoreBoard/Player 1 Scores/p2/2nd score",
	$"ScoreBoard/Player 1 Scores/p3/3rd score",
	$"ScoreBoard/Player 1 Scores/p4/4th score"
]

# Player 2 score labels (same structure)
@onready var p2_scores = [
	$"ScoreBoard/Player 2 Scores/p1/1st score",
	$"ScoreBoard/Player 2 Scores/p2/2nd score",
	$"ScoreBoard/Player 2 Scores/p3/3rd score",
	$"ScoreBoard/Player 2 Scores/p4/4th score"
]

var p1_score_history: Array = []
var p2_score_history: Array = []

func _ready() -> void:
	GameSession.bag_result_changed.connect(_on_bag_result_changed)
	GameSession.turn_changed.connect(_on_turn_changed)
	GameSession.turns_exhausted.connect(_on_match_over)
	_clear_labels()
	print("Player ", GameSession.current_turn, "'s turn")

func _clear_labels() -> void:
	for label in p1_scores:
		label.text = "-"
	for label in p2_scores:
		label.text = "-"
	p1_score_history.clear()
	p2_score_history.clear()

func _on_bag_result_changed(player: int, index: int, points: int) -> void:
	if player == 1:
		if index < 4:
			while p1_score_history.size() <= index:
				p1_score_history.append(0)
			p1_score_history[index] = points
			p1_scores[index].text = str(points)
	else:
		if index < 4:
			while p2_score_history.size() <= index:
				p2_score_history.append(0)
			p2_score_history[index] = points
			p2_scores[index].text = str(points)

func _on_turn_changed(player: int) -> void:
	print("Player ", player, "'s turn")

func _on_match_over() -> void:
	UIManager.enable_canvas(UIManager.result_screen)

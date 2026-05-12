extends CanvasLayer

@onready var winner_text: Label = $"Control/GameOver BG/Dash/Player Winner Declaration"
@onready var p1_score_text: Label = $"Control/GameOver BG/Dash/Player 1 Score"
@onready var p2_score_text: Label = $"Control/GameOver BG/Dash/Label"
@onready var win_message: Label = $"Control/GameOver BG/Win message"
@onready var restart: Button = $"Control/GameOver BG/Rematch"


func _ready() -> void:
	GameSession.turns_exhausted.connect(_update_results)
	NetworkManager.match_forfeit.connect(show_message)
	NetworkManager.rematch_requested.connect(_on_rematch_requested)
	NetworkManager.rematch_declined.connect(_on_rematch_declined)

func _score_key(base_key: String) -> String:
	if GameSession.selected_mode == "Local":
		return base_key
	return "passplay_" + base_key

func _update_results() -> void:
	var p1_score: int = GameSession.score_p1
	var p2_score: int = GameSession.score_p2

	p1_score_text.text = str(p1_score)
	p2_score_text.text = str(p2_score)

	if p1_score > p2_score :
		winner_text.text = "Player 1 Wins"
	elif p2_score > p1_score:
		winner_text.text = "Player 2 Wins"
	else:
		winner_text.text = "You have a tie"
	
	$"Control/GameOver BG/Rematch".disabled = false
	win_message.visible=false

func _on_home_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.home()

func show_message(reason: String) -> void:
	restart.disabled = true
	win_message.visible = true

	if reason == "client left":
		winner_text.text = "Player 1 Wins"
	elif reason == "host left":
		winner_text.text = "Player 2 Wins"
		
	UIManager.enable_canvas(self)


func _on_rematch_pressed() -> void:
	SoundManager.play_button_clicks()
	restart.disabled=true
	NetworkManager.send_rematch_request()

func _on_rematch_requested()->void:
	UIManager.toggle_canvas($"../Rematch popup")


func _on_rematch_declined(message: String) -> void:
	restart.disabled = false
	$"../Rematch popup".visible = false
	$"../WarningPanel".show_alert(message)

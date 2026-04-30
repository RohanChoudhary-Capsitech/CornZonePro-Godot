extends CanvasLayer

func _ready() -> void:
	GameSession.pots_update.connect(update_ui)
	GameSession.match_played.connect(update_ui)
	update_ui()

func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")

func update_ui()->void:
	$"Panel/ProfileBg/Total Pots/Value".text=str(Prefs.get_int("total_pots"))
	$Panel/ProfileBg/GamePlaySection/GamesPlayedValue.text=str(Prefs.get_int("matches_played"))

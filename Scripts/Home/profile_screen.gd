extends CanvasLayer

func _ready() -> void:
	GameSession.pots_update.connect(update_pot_count)
	update_pot_count()

func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")

func update_pot_count()->void:
	$"Panel/ProfileBg/Total Pots/Value".text=str(Prefs.get_int("total_pots"))

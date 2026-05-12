extends CanvasLayer

@export var icons: Array[Texture2D]
@onready var profile_panel = $ProfilePanel

func _ready() -> void:
	GameSession.pots_update.connect(update_ui)
	GameSession.match_played.connect(update_ui)
	update_ui()
	$Panel/ProfileBg/ProfilePic.texture = icons[Prefs.get_int("profile_index", 0)]

func _on_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")

func update_ui()->void:
	$"Panel/ProfileBg/Total Pots/Value".text=str(Prefs.get_int("total_pots"))
	$Panel/ProfileBg/GamePlaySection/GamesPlayedValue.text=str(Prefs.get_int("matches_played"))


func _on_edit_button_pressed() -> void:
	SoundManager.play_button_clicks()
	pass

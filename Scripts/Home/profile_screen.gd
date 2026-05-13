extends CanvasLayer

@export var icons: Array[Texture2D]
@onready var profile_panel = $ProfilePanel

func _ready() -> void:
	GameSession.pots_update.connect(update_ui)
	GameSession.match_played.connect(update_ui)
	update_ui()
	$Panel/ProfileBg/ProfilePic.texture = icons[Prefs.get_int("profile_index", 0)]
	$ProfilePanel.visible = false

func _on_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")

func update_ui()->void:
	$"Panel/ProfileBg/PlayerCard/Total Pots/Value".text=str(Prefs.get_int("total_pots"))
	$Panel/ProfileBg/PlayerCard/GamePlaySection/GamesPlayedValue.text=str(Prefs.get_int("matches_played"))


func _on_edit_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$ProfilePanel.visible = true

func _on_female_icon_pressed() -> void:
	Prefs.set_int("profile_index", 1)
	$Panel/ProfileBg/ProfilePic.texture = icons[1]
	$"../HomeScreen/Panel/Profile/Profile Icon/TextureRect".texture = icons[1]
	$"../InventoryScreen/Panel/Profile/Profile Icon/TextureRect".texture = icons[1]
	$ProfilePanel.visible = false

func _on_male_icon_pressed() -> void:
	Prefs.set_int("profile_index", 0)
	$Panel/ProfileBg/ProfilePic.texture = icons[0]
	$"../HomeScreen/Panel/Profile/Profile Icon/TextureRect".texture = icons[0]
	$"../InventoryScreen/Panel/Profile/Profile Icon/TextureRect".texture = icons[0]
	$ProfilePanel.visible = false
	

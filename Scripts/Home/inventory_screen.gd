extends CanvasLayer

@onready var grid = $Panel/BottomContent/TextureRect/ScrollContainer/Content
@onready var preview = $Panel/PreviewArea

func _ready() -> void:
	$Panel/TopPanel/Coin/CoinText.text = str(Prefs.get_int("coins"))
	grid.item_selected.connect(_on_item_selected)

func _on_item_selected(material):
	preview.set_item_material(material)

func _on_shop_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas($"../ShopScreen")


func _on_play_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.enable_canvas($"../HomeScreen")

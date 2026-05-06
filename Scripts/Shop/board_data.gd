extends TextureRect

@onready var icon = $HBoxContainer/BoardIcon
@onready var rarity_text = $HBoxContainer/VBoxContainer/Rarity
@onready var price_text = $HBoxContainer/VBoxContainer/BagBuyButton/BoardPrice


func setup(data:BoardConfig):
	icon.texture = data.icon
	rarity_text.text = BoardConfig.Rarity.keys()[data.rarity]
	price_text.text = str(data.price) + " Buy"

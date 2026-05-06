extends TextureRect

@export var equip_icon: Texture2D
@export var equipped_icon: Texture2D

@onready var data_icon = $Icon

func setup(icon: Texture2D):
	data_icon.texture = icon

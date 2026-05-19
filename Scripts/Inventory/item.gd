extends Control

signal item_clicked(material)

@export var equip_icon: Texture2D
@export var equipped_icon: Texture2D

@onready var data_icon = $Icon
@onready var button = $Icon/Button
var item_material : Material

func _ready():
	button.pressed.connect(_on_button_pressed)


func setup(data):
	data_icon.texture = data.icon
	item_material = data.material


func _on_button_pressed() -> void:
	item_clicked.emit(item_material)

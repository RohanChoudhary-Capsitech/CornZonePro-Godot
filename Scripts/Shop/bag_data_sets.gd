extends VBoxContainer

@export var bag_scene: PackedScene

func _ready() -> void:
	load_bag_data()

func load_bag_data():
	var data = []

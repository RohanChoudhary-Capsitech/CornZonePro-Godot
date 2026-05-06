extends VBoxContainer
@export var green_signal: Texture2D
@export var white_signal: Texture2D

@export var bag_data_scene: PackedScene
@export var bag_datas : Array[BagConfig] = []

var max_clutch_spot = 50
var max_air_control = 1.5
var max_miss_clock = 4.0
var max_power_shot = 50


func _ready() -> void:
	load_bag_data()

func load_bag_data():
	for child in get_children():
		child.queue_free()
	
	for data in bag_datas:
		if bag_data_scene and data:
			var instance = bag_data_scene.instantiate()
			add_child(instance)
			instance.setup(data, green_signal, white_signal, self)

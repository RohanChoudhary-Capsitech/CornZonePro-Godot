extends VBoxContainer
@export var green_signal: Texture2D
@export var white_signal: Texture2D

@export var bag_data_scene: PackedScene
@export var bag_datas : Array[BagConfig] = []

var max_clutch_spot = 50
var max_air_control = 1.5
var max_miss_time = 4.0
var max_power_shot = 50


func _ready() -> void:
	load_bag_data()

func load_bag_data():
	var data = []

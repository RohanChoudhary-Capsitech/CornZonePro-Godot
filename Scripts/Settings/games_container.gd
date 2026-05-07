extends VBoxContainer

@export var game_icon_scene: PackedScene

@export var data_sets: Array[MoreGameData] = []

func _ready() -> void:
	load_data()
	
func load_data():
	for child in get_children():
		child.queue_free()
	
	for data in data_sets:
		if game_icon_scene and data:
			var instance = game_icon_scene.instantiate()
			add_child(instance)
			instance.setup(data)

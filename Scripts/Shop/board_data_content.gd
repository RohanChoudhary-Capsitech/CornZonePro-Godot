extends VBoxContainer

@export var board_data_scene: PackedScene
@export var board_data: Array[BoardConfig] = []

func _ready() -> void:
	load_board_data();

func load_board_data():
	for child in get_children():
		child.queue_free()
	
	for data in board_data:
		if board_data_scene and data:
			var instance = board_data_scene.instantiate()
			add_child(instance)
			instance.setup(data)

extends GridContainer

@export var item_scene: PackedScene
@export var datas: Array[Texture2D] = []

func _ready() -> void:
	load_data()
	
func load_data():
	for child in get_children():
		child.queue_free()
	
	for data in datas:
		if item_scene and data:
			var instance = item_scene.instantiate()
			add_child(instance)
			instance.setup(data)

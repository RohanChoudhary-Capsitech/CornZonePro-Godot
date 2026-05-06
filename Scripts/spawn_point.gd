extends Node3D

@export var bag:PackedScene

func _ready() -> void:
	$"../StartTimer".start()


func spawn_bag():
	for child in get_children():
		if child.name == "CornBag":
			child.queue_free()

	var obj: Node3D = bag.instantiate() as Node3D

	obj.name = "CornBag"
	obj.rotation_degrees = Vector3(-87.8,0,90)

	obj.set_meta("throw_player", GameSession.current_turn)

	add_child(obj)

	print("SPAWNED:", obj.get_path())

	return obj
	
func _on_timer_timeout() -> void:
	spawn_bag()
	$"../StartTimer".stop()

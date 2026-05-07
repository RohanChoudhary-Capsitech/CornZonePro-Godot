extends Node3D

@export var bag: PackedScene

var bag_counter := 0


func _ready() -> void:
	$"../StartTimer".start()


func spawn_bag():
	var obj = bag.instantiate()

	obj.name = "CornBag_%d" % bag_counter
	obj.set_meta("bag_spawn_index", bag_counter)

	bag_counter += 1

	obj.rotation_degrees = Vector3(-87.8, 0, 90)

	obj.set_meta("throw_player", GameSession.current_turn)

	add_child(obj)

	print("SPAWNED:", obj.get_path())

	return obj


func _on_timer_timeout() -> void:
	spawn_bag()
	$"../StartTimer".stop()

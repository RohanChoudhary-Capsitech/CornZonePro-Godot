extends Node3D

@export var bag:PackedScene

func _ready() -> void:
	$"../StartTimer".start()


func spawn_bag():
	var obj = bag.instantiate()
	obj.rotation_degrees=Vector3(-87.8,0,90)
	add_child(obj)

func _on_timer_timeout() -> void:
	spawn_bag()
	$"../StartTimer".stop()

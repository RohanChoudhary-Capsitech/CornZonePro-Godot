extends Node3D

@export var bag:PackedScene

func _ready() -> void:
	$"../StartTimer".start()


func spawn_bag():
	var obj = bag.instantiate()
	add_child(obj)

func _on_timer_timeout() -> void:
	spawn_bag()
	$"../StartTimer".stop()

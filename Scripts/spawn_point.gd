extends Node3D

@export var bag:PackedScene

func _ready() -> void:
	$"../StartTimer".start()


func spawn_bag():
	var obj: Node3D = bag.instantiate() as Node3D
	obj.rotation_degrees=Vector3(-87.8,0,90)
	obj.set_meta("throw_player", GameSession.current_turn)
	add_child(obj)

func _on_timer_timeout() -> void:
	spawn_bag()
	$"../StartTimer".stop()

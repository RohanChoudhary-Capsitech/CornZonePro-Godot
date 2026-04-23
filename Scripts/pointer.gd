extends Area3D

var score:int = 0

func _on_body_entered(body: Node3D) -> void:
	score += 1
	print("CORNHOLE", score)
	$"../../UI/Label".text = str(score)

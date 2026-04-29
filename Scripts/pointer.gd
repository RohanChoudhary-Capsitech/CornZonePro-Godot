extends Area3D

var score:int = 0

func _on_body_entered(body: Node3D) -> void:
	if GameSession.mode_logic:
		GameSession.mode_logic.on_ball_entered(body)
	#$"../../InGame UI/Label".text = str(score)

extends Area3D

var score:int = 0

func _on_body_entered(body: Node3D) -> void:
	GameSession.add_score(GameSession.current_turn,1)
	print(GameSession.score_p1)
	#$"../../InGame UI/Label".text = str(score)

extends Node

const BAGS_PER_PLAYER := 4

var p1_bags_thrown: int = 0
var p2_bags_thrown: int = 0
var results_saved: bool = false

func is_network_game() -> bool:
	return GameSession.selected_mode == "Local"

func is_host() -> bool:
	return multiplayer.is_server()

func on_ball_entered(body: Node3D) -> void:
	# 🟢 LOCAL MODE
	if not is_network_game():
		_apply_score(body)
		return

	# 🌐 NETWORK MODE → ONLY HOST
	if not is_host():
		return

	_apply_score(body)
	sync_score.rpc(GameSession.score_p1, GameSession.score_p2)

func on_bag_thrown() -> void:
	# 🟢 LOCAL MODE → unchanged
	if not is_network_game():
		_apply_bag_thrown()
		return

	# 🌐 NETWORK MODE
	if not is_host():
		request_bag_thrown.rpc_id(1)
		return

	_apply_bag_thrown()

func _apply_bag_thrown():
	if GameSession.current_turn == 1:
		p1_bags_thrown += 1
	else:
		p2_bags_thrown += 1

	if p1_bags_thrown >= BAGS_PER_PLAYER and p2_bags_thrown >= BAGS_PER_PLAYER:
		_save_scores()
		GameSession.end_match()
		GameSession.turns_exhausted.emit()
	else:
		GameSession.current_turn = 2 if GameSession.current_turn == 1 else 1
		GameSession.turn_changed.emit(GameSession.current_turn)

	# 🌐 sync
	if is_network_game():
		sync_state.rpc(GameSession.current_turn, p1_bags_thrown, p2_bags_thrown)

func on_match_end() -> void:
	if not results_saved and (GameSession.score_p1 > 0 or GameSession.score_p2 > 0):
		_save_scores()
	_reset_round()
	# no coins for local multiplayer

func _reset_round() -> void:
	p1_bags_thrown = 0
	p2_bags_thrown = 0
	results_saved = false

func _save_scores() -> void:
	if results_saved:
		return

	Prefs.set_int("last_score_p1", GameSession.score_p1)
	Prefs.set_int("last_score_p2", GameSession.score_p2)
	
	# track wins
	if GameSession.score_p1 > GameSession.score_p2:
		var wins: int = int(Prefs.get_int("p1_wins", 0))
		Prefs.set_int("p1_wins", wins + 1)
	elif GameSession.score_p2 > GameSession.score_p1:
		var wins: int = int(Prefs.get_int("p2_wins", 0))
		Prefs.set_int("p2_wins", wins + 1)

	Prefs.save()
	results_saved = true


@rpc("any_peer", "reliable")
func request_bag_thrown():
	if not is_host():
		return
	_apply_bag_thrown()

@rpc("any_peer", "reliable")
func sync_state(turn: int, p1: int, p2: int):
	GameSession.current_turn = turn
	p1_bags_thrown = p1
	p2_bags_thrown = p2
	GameSession.turn_changed.emit(turn)

@rpc("any_peer", "reliable")
func sync_score(p1: int, p2: int):
	GameSession.score_p1 = p1
	GameSession.score_p2 = p2
	GameSession.score_changed.emit()



func _apply_score(body):
	var scoring_player: int = GameSession.current_turn
	if body.has_meta("throw_player"):
		scoring_player = int(body.get_meta("throw_player"))

	var awarded_points: int = int(body.get_meta("awarded_points", 0))
	var delta: int = maxi(0, 3 - awarded_points)

	body.set_meta("awarded_points", 3)
	GameSession.add_score(scoring_player, delta)

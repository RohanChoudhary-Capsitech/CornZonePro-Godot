# Equivalent of StatsManager.cs (ELO logic)
extends Node

# K-factor controls how much ELO changes per match
const K_FACTOR = 32

func update_elo(opponent_elo: int, player_won: bool):
	var expected = _expected_score(PlayerData.elo, opponent_elo)
	var actual = 1.0 if player_won else 0.0
	var delta = int(K_FACTOR * (actual - expected))
	PlayerData.elo = max(0, PlayerData.elo + delta)

	if player_won:
		PlayerData.matches_won += 1
	else:
		PlayerData.matches_lost += 1

	# Recalculate K/D (avoid divide by zero)
	if PlayerData.matches_lost > 0:
		PlayerData.kd = float(PlayerData.matches_won) / float(PlayerData.matches_lost)
	else:
		PlayerData.kd = float(PlayerData.matches_won)

	PlayerData.matches_played = PlayerData.matches_won + PlayerData.matches_lost
	_update_rank()

func _expected_score(player_elo: int, opponent_elo: int) -> float:
	return 1.0 / (1.0 + pow(10.0, float(opponent_elo - player_elo) / 400.0))

func _update_rank():
	if PlayerData.elo >= 2000:
		PlayerData.rank = "Diamond"
	elif PlayerData.elo >= 1600:
		PlayerData.rank = "Platinum"
	elif PlayerData.elo >= 1300:
		PlayerData.rank = "Gold"
	elif PlayerData.elo >= 1100:
		PlayerData.rank = "Silver"
	elif PlayerData.elo >= 900:
		PlayerData.rank = "Bronze"
	else:
		PlayerData.rank = "Unranked"

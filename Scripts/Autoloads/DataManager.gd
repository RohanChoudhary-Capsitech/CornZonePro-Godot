extends Node

signal coins_changed

func add_coins(earned_coins: int) -> void:
	var current_coins: int = Prefs.get_int("coins", 0)
	current_coins += earned_coins
	Prefs.set_int("coins", current_coins)
	coins_changed.emit()
	print(" Total: ", current_coins)

func get_coins()->int:
	return Prefs.get_int("coins",0)

func spend_coins(amount:int)->bool:
	var current: int = get_coins()
	if current<amount:
		print("Not enough coins")
		return false
	Prefs.set_int("coins",current-amount)
	print("Spent: ", amount, " | Remaining: ", get_coins())
	coins_changed.emit()
	return true

func match_played()->void:
	var matches:int=Prefs.get_int("matches_played",0)
	matches += 1
	Prefs.set_int("matches_played",matches)
	Prefs.save()
	

# Daily Reward Tracking

func get_current_day() -> int:
	return Prefs.get_int("reward_day", 1)

func get_last_claim_time() -> float:
	return Prefs.get_float("last_claim_time", 0.0)
	
func can_claim() -> bool:
	var current_time = Time.get_unix_time_from_system()
	var seconds_passed = current_time - get_last_claim_time()
	return seconds_passed >= 86400 or get_last_claim_time() == 0

func check_streak_status():
	var last_time_claim = get_last_claim_time()
	if last_time_claim == 0: return
	
	var current_time = Time.get_unix_time_from_system()
	var seconds_passed = current_time - last_time_claim
	
	if seconds_passed >= 172800:
		Prefs.set_int("reward_day", 1)
		Prefs.save()
		print("Streak broken, Reset to day 1")
	
func save_claim_success():
	Prefs.set_float("last_claim_time", Time.get_unix_time_from_system())
	var next_day = get_current_day() + 1
	if next_day > 7: next_day = 1
	Prefs.set_int("reward_day", next_day)
	
	Prefs.save()

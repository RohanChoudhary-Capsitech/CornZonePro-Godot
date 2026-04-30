extends Node

func add_coins(earned_coins: int) -> void:
	if earned_coins <= 0:
		push_error("Invalid coin amount: " + str(earned_coins))
		return
	var current_coins: int = Prefs.get_int("coins", 0)
	current_coins += earned_coins
	Prefs.set_int("coins", current_coins)
	print("Coins: +", earned_coins, " | Total: ", current_coins)

func get_coins()->int:
	return Prefs.get_int("coins",0)

func spend_coins(amount:int)->bool:
	var current=get_coins()
	if current<amount:
		print("Not enough coins")
		return false
	Prefs.set_int("coins",current-amount)
	print("Spent: ", amount, " | Remaining: ", get_coins())
	return true

func match_played()->void:
	var matches:int=Prefs.get_int("matches_played",0)
	matches += 1
	Prefs.set_int("matches_played",matches)
	Prefs.save()
	
	

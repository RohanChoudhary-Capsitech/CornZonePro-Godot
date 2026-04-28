extends Node

func add_coins(earned_coin:int)->void:
	var inventory_coins:int=Prefs.get_int("coins",0)
	inventory_coins+=earned_coin
	Prefs.set_int("coins",inventory_coins)
	Prefs.save()
	print(inventory_coins)

extends VBoxContainer

@export var row_data: PackedScene

func  _ready() -> void:
	load_leaderboard()
	
func load_leaderboard():
	var data = [
		{"rank":1, "name":"Himanshu", "score":120},
		{"rank":2, "name":"Chintu", "score":110},
		{"rank":3, "name":"Mohan", "score":100},
		{"rank":4, "name":"Sundanshu", "score":90},
		{"rank":5, "name":"Mukesh", "score":80},
		{"rank":6, "name":"Rohit", "score":70},
		{"rank":7, "name":"Kanha", "score":60},
		{"rank":8, "name":"Bodhesh", "score":50},
		{"rank":9, "name":"Chandan", "score":40},
		{"rank":10,"name":"Utkasrsh","score":30}
	]
	
	for player in data:
		var row = row_data.instantiate()
		add_child(row)
		row.setup(player)

extends VBoxContainer

@export var row_data: PackedScene


func _ready() -> void:

	# Connect signal once
	if not LeaderboardManager.leaderboard_loaded.is_connected(_on_leaderboard_loaded):

		LeaderboardManager.leaderboard_loaded.connect(_on_leaderboard_loaded)

	load_leaderboard()


func load_leaderboard():

	# Fetch leaderboard from Firebase
	await LeaderboardManager.fetch_top(false)


func _on_leaderboard_loaded(entries: Array, my_rank: int):


	# Clear old rows
	for child in get_children():

		child.queue_free()


	# Create leaderboard rows
	for i in range(entries.size()):

		var entry = entries[i]

		var player_data = {
			"rank": i + 1,
			"name": entry.get("player_name", "Unknown"),
			"score": entry.get("Coins", 0),
			"uid": entry.get("uid", "")
		}


		var row = row_data.instantiate()

		add_child(row)

		row.setup(player_data)


		# Highlight current player
		if player_data["uid"] == FirebaseManager.player_id:
			row.modulate = Color.YELLOW

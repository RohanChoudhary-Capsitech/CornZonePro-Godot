extends Node

# GameSession.gd
const UI_SCENES = {
	"Single": preload("res://Scenes/single_player_ui.tscn"),
	#"PassPlay": preload(),
	#"Local": preload()
}

signal score_changed

var return_home:bool=false

var selected_map_path:String = ""
var selected_mode:String = ""
var required_ui:String=""

var player_count: int = 1
var current_turn: int = 1

var score_p1: int = 0
var score_p2: int = 0
var time_left: float = 20.0


func start_match(mode: String, map_path: String,ui:String, time_limit: float) -> void:
	selected_mode = mode
	selected_map_path = map_path
	required_ui=ui

	# Decide players based on mode
	match mode:
		"Single":
			player_count = 1
		"PassPlay":
			player_count = 2
		"Local":
			player_count = 2

	current_turn = 1
	score_p1 = 0
	score_p2 = 0
	time_left = time_limit

func add_score(player: int, amount: int) -> void:
	if player == 1:
		score_p1 += amount
	elif player == 2:
		score_p2 += amount
	
	score_changed.emit()


func next_turn() -> void:
	if player_count <= 1:
		return

	current_turn += 1
	if current_turn > player_count:
		current_turn = 1


func reset_match() -> void:
	selected_mode = ""
	selected_map_path = ""
	player_count = 1
	current_turn = 1
	score_p1 = 0
	score_p2 = 0
	time_left = 20.0
 

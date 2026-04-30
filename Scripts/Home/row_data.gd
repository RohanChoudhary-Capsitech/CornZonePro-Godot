extends TextureRect

@onready var rank_label = $Rank
@onready var name_label = $Username
@onready var score_label = $ScoreGroup/Score

func setup(data):
	rank_label.text = str(data.rank)
	name_label.text = data.name
	score_label.text = str(data.score)

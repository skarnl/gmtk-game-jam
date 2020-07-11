extends Control

onready var score_text = $score_text

func _ready():
	reset()

func set_score(score):
	print("score = ", score)
	
	score_text.text = str(score)

func reset():
	set_score(0)

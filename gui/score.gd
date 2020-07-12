extends Control

func _ready():
	reset()


func set_enemies_killed(number):
	$enemy_text.text = 'Enemies killed: %s' % str(number)


func set_score(score):
	$score_text.text = 'Score: %s' % str(score)

func reset():
	set_score(0)
	set_enemies_killed(0)

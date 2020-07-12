extends Control


func _ready():
	hide()
	

func show_gameover(restart_count):
	.show()
	
	$text.text = _get_random_encouragement(restart_count)

func _get_random_encouragement(restart_count):
	if restart_count == 0:
		return 'awww, you got hit. Don\'t worry, we\'ve all been there. Just try again. You\'ll get the hang of it'
	else:
		var sentences = [
			'common, is this the best you can do?', 
			'let\'s try that again', 
			'wow, they came out of nowhere', 
			'OMG! This is Out of Control (pun intended)',
			'next time try to avoid the red blobbly thingies',
			'one more try?',
			'i know you can do it! come on!',
			'let\'s forget about this mistake and try again, shall we?',
			'more after the break',
			'no need to cry, we all make mistakes',
			'not sure what happend there',
			'uhm ... you know you have to avoid the monsters, right?',
			'well, let\'s never talk about this misstep',
			'you almost dodged them! ... almost',
			'ok ... white thing is you, red thing is bad',
			]
		randomize()
		sentences.shuffle()
		return sentences.front()

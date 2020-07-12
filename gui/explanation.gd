extends Control


var first_time = true

func _ready():
	hide()
	$Timer.connect('timeout', self, '_on_Timer_timeout')

func show():	
	.show()
	$AnimationPlayer.play('_setup')	
	

func start_hide_timeout():
	$Timer.start()

	
func _on_Timer_timeout():
	$AnimationPlayer.play('fade')
	
	yield($AnimationPlayer, 'animation_finished')
	
	hide()
	
func reset():
	$Timer.stop()
	hide()

	if first_time:
		$Label.text += '\nok, also the \'r\' key'
		first_time = false

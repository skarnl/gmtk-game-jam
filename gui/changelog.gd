extends Control

func _ready():
	RandomEffectController.connect('effect_applied', self, '_on_REC_effect_applied')
	
func _on_REC_effect_applied(logEntry):
	$Logs.text += '%s\n' % logEntry

func reset():
	$Logs.text = ''

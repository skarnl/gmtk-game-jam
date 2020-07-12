extends Node

signal effect_applied

var powerups = []
var effects = []

func _ready():
	randomize()

func register_effect(callee, functionName, logDescription):
	assert(callee.has_method(functionName))
	
	var effect = {
		callee = callee,
		functionName = functionName,
		logDescription = logDescription
	}
	
	effects.append(effect)

func register_powerup(powerup_ref):
	powerup_ref.connect('pickedup', self, '_on_Powerup_pickedup')

func _on_Powerup_pickedup():
	_call_random_effect()

func _call_random_effect():
	randomize()
	
	effects.shuffle()
	var effect = effects.front()
	
	if effect.callee:
		var callbackFunction = funcref(effect.callee, effect.functionName)
		callbackFunction.call_func()
	
		emit_signal('effect_applied', effect.logDescription)
	
	
	
	

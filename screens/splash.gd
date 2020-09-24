extends Node2D

var rng 

func _ready():
	if OS.is_debug_build():
		Game.transition_to(Game.MAIN_MENU)
		pass
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	randomize()
	
	$ColorRect.color = Color8(rng.randi_range(0, 100), rng.randi_range(0, 100), rng.randi_range(0, 100))
	_tween_color()
	
	var animation = ['intro', 'intro_alternative']
	animation.shuffle()
	
	$AnimationPlayer.playback_speed = rng.randf_range(1.9, 3.3)
	$AnimationPlayer.play(animation.front())
	
	yield($AnimationPlayer, 'animation_finished')
	
	$RaksoAnimationPlayer.play('intro')
	
	yield($RaksoAnimationPlayer, 'animation_finished')
	
	Game.transition_to(Game.GameState.MAIN_MENU)

func _input(event):
	if event is InputEventKey and event.is_action_pressed('ui_accept'):
		Game.transition_to(Game.GameState.MAIN_MENU)

func _tween_color():
	var target_color = Color8(rng.randi_range(0, 100), rng.randi_range(0, 100), rng.randi_range(0, 100))

	$Tween.interpolate_property($ColorRect, 'color', $ColorRect.color, target_color, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	
	yield($Tween, 'tween_completed')
	
	_tween_color()
	

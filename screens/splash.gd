extends Node2D


func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	randomize()
	
	$ColorRect.color = Color8(rng.randi_range(0, 100), rng.randi_range(0, 100), rng.randi_range(0, 100))
	
	var animation = ['intro', 'intro_alternative']
	animation.shuffle()
	
	$AnimationPlayer.playback_speed = rng.randf_range(1.9, 3.3)
	$AnimationPlayer.play(animation.front())
	
	yield($AnimationPlayer, 'animation_finished')
	
	if not OS.is_debug_build():
		yield(get_tree().create_timer(2.3), 'timeout')
	
	Game.transition_to(Game.GameState.MAIN_MENU)

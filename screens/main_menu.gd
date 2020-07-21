extends Node2D

var game_started = false

func _input(event):
	if event is InputEventKey and event.is_action_pressed('ui_accept'):
		start_game()
	
	if event is InputEventMouseButton:
		start_game()

func start_game():
	if game_started:
		return

	game_started = true
	
	$StartGamePlayer.play('start_game')
		
	yield($StartGamePlayer, 'animation_finished')
		
	Game.start_game()

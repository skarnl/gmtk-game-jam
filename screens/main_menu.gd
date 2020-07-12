extends Node2D

func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		$StartGamePlayer.play('start_game')
		
		yield($StartGamePlayer, 'animation_finished')
		
		Game.start_game()

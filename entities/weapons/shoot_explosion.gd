extends Sprite


func _ready():
	$AnimationPlayer.play('explode')
	
	yield($AnimationPlayer, 'animation_finished')
	
	queue_free()

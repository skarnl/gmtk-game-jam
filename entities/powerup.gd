extends Area2D

signal pickedup

func _ready():
	print("powerup spawned")
	
	add_to_group('spawned')
	
	RandomEffectController.register_powerup(self)
	$AnimationPlayer.play('spawn')
	

func _on_Area2D_body_entered(body):
	call_deferred('_disable_collisions')
	emit_signal('pickedup')
	
	$AnimationPlayer.play('pickup')

	yield($AnimationPlayer, 'animation_finished')
	
	queue_free()


func _disable_collisions():
	$CollisionShape2D.disabled = true

extends Area2D

const BULLET_SPEED = 3.6

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * BULLET_SPEED


# remove when out of screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

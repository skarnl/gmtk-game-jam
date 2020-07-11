extends KinematicBody2D
class_name Bullet

const BULLET_SPEED = 1.6

func _physics_process(delta):
	move_and_collide(Vector2.RIGHT.rotated(rotation) * BULLET_SPEED)


# remove when out of screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

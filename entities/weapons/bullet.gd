extends Area2D

const BULLET_SPEED = 7

func _ready():
	add_to_group('spawned')

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * BULLET_SPEED


# remove when out of screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

extends KinematicBody2D

signal player_hit
signal enemy_killed

const BASE_WALKING_SPEED = 100 #RANDOMIZE
const BASE_POINTS_WHEN_KILLED = 1
const MOVEMENT_SPEED_POINTS_RATIO = 0.1

var points_when_killed
var player_reference

var movement_speed

func _ready():
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	add_to_group('spawned')
	
	var nodes = get_tree().get_nodes_in_group('player')
	player_reference = nodes.front()
	
	movement_speed = BASE_WALKING_SPEED + rnd.randf_range(-30, 100)
	points_when_killed = max(1, BASE_POINTS_WHEN_KILLED + (movement_speed - 100) * MOVEMENT_SPEED_POINTS_RATIO)

func _physics_process(delta):
	if not player_reference:
		return
		
	var motion = (player_reference.get_global_position() - global_position)
	move_and_slide(motion.normalized() * movement_speed)
	
	var flip = motion.normalized().x > 0
	$Sprite.flip_h = flip
	
	var collisionScale = $Area2D/CollisionPolygon2D.scale
	
	if flip:
		collisionScale.x = -1
	else:
		collisionScale.x = 1

	$Area2D/CollisionPolygon2D.scale = collisionScale


func _disable_collisions():
	$CollisionShape2D.disabled = true
	$Area2D/CollisionPolygon2D.disabled = true


#bullet
func _on_Area2D_area_entered(area):
	set_physics_process(false)
	call_deferred('_disable_collisions')
	emit_signal('enemy_killed')

#	area.queue_free()
	
	$AnimationPlayer.play('die')
	$DeathSound.play()
	
	yield($DeathSound, 'finished')
	
	queue_free()
	

#player
func _on_Area2D_body_entered(body):
	set_physics_process(false)
	call_deferred('_disable_collisions')
	
	emit_signal('player_hit')

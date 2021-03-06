extends KinematicBody2D

signal player_hit
signal enemy_killed

const BASE_WALKING_SPEED = 100 #RANDOMIZE
const BASE_POINTS_WHEN_KILLED = 1
const MOVEMENT_SPEED_POINTS_RATIO = 0.1

var points_when_killed
var player_reference

var points = preload('res://gui/points.tscn')

var movement_speed
var rnd

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	add_to_group('spawned')
	
	var nodes = get_tree().get_nodes_in_group('player')
	player_reference = nodes.front()
	
	movement_speed = BASE_WALKING_SPEED + rnd.randf_range(-30, 100)
	points_when_killed = stepify(max(1, BASE_POINTS_WHEN_KILLED + (movement_speed - 100) * MOVEMENT_SPEED_POINTS_RATIO), 0.01) * 100


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


func get_information():
	var text = 'points_when_killed: %s\n' % points_when_killed
	text += 'movement_speed: %s\n' % movement_speed
	
	return text


func get_movement_speed():
	return movement_speed

func set_movement_speed(_movement_speed):
	movement_speed = _movement_speed
	
func get_points_when_killed():
	return points_when_killed
	
func set_points_when_killed(_points):
	points_when_killed = _points
	

#bullet
func _on_Area2D_area_entered(area):
	set_physics_process(false)
	call_deferred('_disable_collisions')
	
	remove_from_group('enemies')
	
	emit_signal('enemy_killed')

	_spawn_points()
	
	$AnimationPlayer.play('die')
	$DeathSound.play()
	
	yield($DeathSound, 'finished')
	
	queue_free()
	
func _spawn_points():
	var points_instance = points.instance()
	points_instance.text = str(points_when_killed)
	
	add_child(points_instance)

#player
func _on_Area2D_body_entered(body):
	set_physics_process(false)
	call_deferred('_disable_collisions')
	
	emit_signal('player_hit')

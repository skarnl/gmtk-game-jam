extends KinematicBody2D

signal player_killed
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
	
	print("movement_speed = ", movement_speed)
	print("points_when_killed = ", points_when_killed)

func _physics_process(delta):
	if not player_reference:
		return
		
	var motion = (player_reference.get_global_position() - global_position)
	move_and_slide(motion.normalized() * movement_speed)
	
	$Sprite.flip_h = motion.normalized().x > 0
	
#	look_at(player_reference.position)


#bullet
func _on_Area2D_area_entered(area):
	emit_signal('enemy_killed')

	queue_free()
	area.queue_free()
	

#player
func _on_Area2D_body_entered(body):
	emit_signal('player_killed')

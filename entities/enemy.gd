extends KinematicBody2D

signal player_killed
signal enemy_killed

const BASE_WALKING_SPEED = 100 #RANDOMIZE

var points_when_killed = 1
var player_reference

var movement_speed

func _ready():
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	add_to_group('spawned')
	
	var nodes = get_tree().get_nodes_in_group('player')
	player_reference = nodes.front()
	
	movement_speed = BASE_WALKING_SPEED + rnd.randf_range(-30, 60)

func _physics_process(delta):
	if not player_reference:
		return
		
	var motion = (player_reference.get_global_position() - global_position)
	move_and_slide(motion.normalized() * movement_speed)
	look_at(player_reference.position)


#bullet
func _on_Area2D_area_entered(area):
	emit_signal('enemy_killed')

	queue_free()
	area.queue_free()
	

#player
func _on_Area2D_body_entered(body):
	emit_signal('player_killed')

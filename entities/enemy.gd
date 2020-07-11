extends KinematicBody2D

signal player_killed
signal enemy_killed

const WALKING_SPEED = 100 #RANDOMIZE

var points_when_killed = 3
var player_reference

func _ready():
	add_to_group('spawned')
	
	var nodes = get_tree().get_nodes_in_group('player')
	player_reference = nodes.front()

func _physics_process(delta):
	if not player_reference:
		return
		
	var motion = (player_reference.get_global_position() - global_position)
	move_and_slide(motion.normalized() * WALKING_SPEED)
	look_at(player_reference.position)


#bullet
func _on_Area2D_area_entered(area):
	emit_signal('enemy_killed')

	queue_free()
	area.queue_free()
	

#player
func _on_Area2D_body_entered(body):
	emit_signal('player_killed')

extends KinematicBody2D

const WALKING_SPEED = 100 #RANDOMIZE

var player_reference

func _ready():
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
	print(area)
	queue_free()
	area.queue_free()

#player
func _on_Area2D_body_entered(body):
	print(body)
	
	body.queue_free()
	pass # Replace with function body.

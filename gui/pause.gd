extends Control

var label = preload('res://gui/information_label.tscn')

var _global_information

func _ready():
	hide()
	
func show():
	for child in $labels.get_children():
		$labels.remove_child(child)
		child.queue_free()
	
	_render_global_info()
	_render_player_info()
	_render_enemy_info()
	
	.show()
	
func set_global_information(information):
	_global_information = information


func _render_global_info():
	_add_label(Vector2(10, 10), _global_information)


func _render_player_info():
	var playerNodes = get_tree().get_nodes_in_group('player')
	var player = playerNodes.front()
	
	var information = player.get_information()
	
	_add_label(player.global_position, information)
	

func _render_enemy_info():
	var enemiesNodes = get_tree().get_nodes_in_group('enemies')
	
#	var bulletsNodes = get_tree().get_nodes_in_group('bullets')

	for enemy in enemiesNodes:
		_add_label(enemy.global_position, enemy.get_information())
	
	
func _add_label(position, information):
	var new_label: Control = label.instance()
	new_label.rect_position = position
	new_label.get_node('Label').text = information
	
	$labels.add_child(new_label)

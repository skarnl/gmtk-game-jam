extends Node2D

var enemy_ref = preload('res://entities/enemy.tscn')

var screen_size = Vector2.ZERO
var rnd

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	screen_size = get_viewport().size
	
	$EnemyTimer.connect('timeout', self, '_on_EnemyTimer_timeout')
	
	$Player.connect('change_time_changed', self, '_on_Player_change_time_changed')


func _on_EnemyTimer_timeout():
	#TODO check hoeveel enemies we hier al hebben
	spawn_enemy()
	

func spawn_enemy():
	var enemy = enemy_ref.instance()
	enemy.position = Vector2(rnd.randf_range(0, screen_size.x), rnd.randf_range(0, screen_size.y))
	
	print("spawn enemy")
	print(enemy.position)
	
	add_child(enemy)


func _on_Player_change_time_changed(time_left):
	$HUD/Timers.update_change_time(time_left)

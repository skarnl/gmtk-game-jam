extends Node2D

onready var enemy_timer = $'../EnemyTimer'
onready var player = $'../Player'

var enemy_ref = preload('res://entities/enemy.tscn')

var screen_size = Vector2.ZERO
var rnd

const DEFAULT_ENEMY_SPAWN_TIME = 3
const ENEMY_DIFFICULTY_RATIO = 0.97

var _score = 0

enum STATES {
	PLAY,
	PAUSED,
	GAME_OVER,
	RESTART
}

var _current_state = STATES.PLAY

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	screen_size = get_viewport().size
	
	enemy_timer.connect('timeout', self, '_on_EnemyTimer_timeout')
	
	player.connect('change_time_changed', self, '_on_Player_change_time_changed')
	player.connect('debug', self, '_on_Player_debug')
	
	spawn_enemy()

func _on_Player_debug(text):
	text += 'EnemySpawnRate: %s' % enemy_timer.wait_time
	$'../HUD/Debug'.set_text(text)	

func _on_EnemyTimer_timeout():
	#TODO check hoeveel enemies we hier al hebben
	spawn_enemy()
	

func spawn_enemy():
	var enemy = enemy_ref.instance()
	var player_position = player.global_position
	var enemy_position = player_position
	
	while enemy_position.distance_to(player_position) < 150:
		print("pre distance = ", enemy_position.distance_to(player_position))
	
		enemy_position = Vector2(rnd.randf_range(0, screen_size.x), rnd.randf_range(0, screen_size.y))
	
	print("post distance = ", enemy_position.distance_to(player_position))
	
	enemy.position = enemy_position
	
	enemy.connect('enemy_killed', self, '_on_enemy_killed', [enemy])
	enemy.connect('player_killed', self, '_on_player_killed')
	
	get_parent().add_child(enemy)


func _on_Player_change_time_changed(time_left):
	$'../HUD/Timers'.update_change_time(time_left)

func _on_enemy_killed(enemy):
	_update_score(enemy.points_when_killed)
	_increase_difficulty()

func _on_player_killed():
	_change_state(STATES.GAME_OVER)
	
	
func _increase_difficulty():
	enemy_timer.wait_time *= ENEMY_DIFFICULTY_RATIO 
	
func _update_score(amount):
	_score += amount
	$'../HUD/Score'.set_score(_score)
	
func reset():
	_score = 0
	$'../HUD/Score'.reset()
	player.reset()
	_hide_game_over()
	
	var allSpawnedEntities = get_tree().get_nodes_in_group('spawned')
	for entity in allSpawnedEntities:
		entity.queue_free()
		
	enemy_timer.stop()
		
	yield(get_tree(), 'idle_frame')
	
	enemy_timer.wait_time = DEFAULT_ENEMY_SPAWN_TIME
	enemy_timer.start()
	spawn_enemy()
	

func _set_paused(pause):
	get_tree().paused = pause
	

func _change_state(new_state):
	match new_state:
		STATES.PLAY:
			if _current_state == STATES.GAME_OVER:
				_current_state = new_state
				reset()
				_set_paused(false)
			if _current_state == STATES.PAUSED:
				_current_state = new_state
				_set_paused(false)
		
		STATES.GAME_OVER:
			if _current_state == STATES.PLAY:
				_current_state = new_state
				_set_paused(true)
				_show_game_over()
				
		STATES.PAUSED:
			if _current_state == STATES.PLAY:
				_current_state = new_state
				_set_paused(true)
				_show_paused_overlay()
				
		STATES.RESTART:
			_current_state = STATES.PLAY
			reset()
			_set_paused(false)

func _show_game_over():
	$'../HUD/GameOver/PopupDialog'.popup()

func _hide_game_over():
	$'../HUD/GameOver/PopupDialog'.hide()

func _show_paused_overlay():
	print("show overlay")
	pass

func _unhandled_key_input(event):
	print("unhandled key input")
	
	print(event)
	
	if event.is_action_pressed('ui_paused'):
		_change_state(STATES.PAUSED)
	
	if event.is_action_pressed('ui_restart'):
		print("RESTART PRESSED")
		_change_state(STATES.RESTART)
	
	
	
	
	

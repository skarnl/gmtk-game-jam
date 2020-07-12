extends Node2D

onready var enemy_timer = $'../EnemyTimer'
onready var player = $'../Player'

var enemy_ref = preload('res://entities/enemy.tscn')
var powerup_ref = preload('res://entities/powerup.tscn')

var screen_size = Vector2.ZERO
var rnd

const DEFAULT_ENEMY_SPAWN_TIME = 3
const ENEMY_DIFFICULTY_RATIO = 0.97
const DEFAULT_POWERUP_CHANCE = 0.3

var _score = 0
var _enemies_killed = 0
var restart_count = 0
var _powerup_chance = DEFAULT_POWERUP_CHANCE

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
	
	enemy_timer.wait_time = DEFAULT_ENEMY_SPAWN_TIME
	enemy_timer.connect('timeout', self, '_on_EnemyTimer_timeout')
	
	player.connect('change_time_changed', self, '_on_Player_change_time_changed')
	player.connect('shooting', self, '_on_Player_shooting')
	player.connect('moved', self, '_on_Player_moved')
	player.connect('debug', self, '_on_Player_debug')
	
	_register_effects()
	
	$'../HUD/GameOver'.hide()
	
	yield(get_tree(), 'idle_frame')
	
	$'../explanation'.show()
	

func _register_effects():
	RandomEffectController.register_effect(self, 'increase_powerup_chance', 'Increase Powerup Drop Chance')
	RandomEffectController.register_effect(self, 'decrease_powerup_chance', 'Decrease Powerup Drop Chance')
	RandomEffectController.register_effect(self, 'randomize_powerup_chance', 'Randomize Powerup Drop Chance')
	RandomEffectController.register_effect(self, 'increase_enemy_spawn_rate', 'Increase Enemy spawn rate')
	RandomEffectController.register_effect(self, 'decrease_enemy_spawn_rate', 'Decrease Enemy spawn rate')
	RandomEffectController.register_effect(self, 'randomize_enemy_spawn_rate', 'Randomize Enemy spawn rate')
	RandomEffectController.register_effect(self, 'spawn_enemy', 'Spawn Enemy')
	RandomEffectController.register_effect(self, 'increase_random_enemy_movement_speed', 'Increase Enemy movement speed')
	RandomEffectController.register_effect(self, 'decrease_random_enemy_movement_speed', 'Decrease Enemy movement speed')
	RandomEffectController.register_effect(self, 'randomize_random_enemy_movement_speed', 'Randomize Enemy movement speed')
	RandomEffectController.register_effect(self, 'increase_random_enemy_points', 'Increase Enemy points')
	RandomEffectController.register_effect(self, 'decrease_random_enemy_points', 'Decrease Enemy points')
	RandomEffectController.register_effect(self, 'randomize_random_enemy_points', 'Randomize Enemy points')

func increase_powerup_chance():
	print("increase powerup chance")
	
	_powerup_chance += 0.1

func decrease_powerup_chance():
	print("decrease powerup chance")
	
	_powerup_chance -= 0.1


func randomize_powerup_chance():
	print("randomize powerup chance")
	
	_powerup_chance = rnd.randf_range(0.1, 1)
	
func increase_enemy_spawn_rate():
	print("increase_enemy_spawn_rate")
	_increase_difficulty()
	
func decrease_enemy_spawn_rate():
	print("decrease_enemy_spawn_rate")
	_decrease_difficulty()

func randomize_enemy_spawn_rate():
	enemy_timer.wait_time = rnd.randf_range(0.1, DEFAULT_ENEMY_SPAWN_TIME)


func _get_random_enemy():
	var enemyNodes = get_tree().get_nodes_in_group('enemies')
	enemyNodes.shuffle()
	
	return enemyNodes.front()

func increase_random_enemy_movement_speed():
	var enemy = _get_random_enemy()
	var speed = enemy.get_movement_speed()
	enemy.set_movement_speed(speed * 1.1)
	
func decrease_random_enemy_movement_speed():
	var enemy = _get_random_enemy()
	var speed = enemy.get_movement_speed()
	enemy.set_movement_speed(speed * 0.9)
	
func randomize_random_enemy_movement_speed():
	var enemy = _get_random_enemy()
	enemy.set_movement_speed(rnd.randf_range(-130, 200))
	
func increase_random_enemy_points():
	var enemy = _get_random_enemy()
	var points = enemy.get_points_when_killed()
	enemy.set_points_when_killed(points * 1.1)
	
func decrease_random_enemy_points():
	var enemy = _get_random_enemy()
	var points = enemy.get_points_when_killed()
	enemy.set_points_when_killed(points * 0.9)
	
func randomize_random_enemy_points():
	var enemy = _get_random_enemy()
	enemy.set_points_when_killed(rnd.randf_range(0, 1000))

func _on_Player_debug(text):
	text += 'EnemySpawnRate: %s' % enemy_timer.wait_time
	$'../HUD/Debug'.set_text(text)	

func _on_EnemyTimer_timeout():
	spawn_enemy()

func _on_Player_moved():
	player.disconnect('moved', self, '_on_Player_moved')
	
	$'../explanation'.start_hide_timeout()
	
	yield(get_tree().create_timer(2.3), 'timeout')
	
	spawn_enemy()

	
func _on_Player_shooting():
	$'../Camera2D'.add_trauma(0.2)
	

func spawn_enemy():
	if _current_state == STATES.PAUSED:
		return
	
	var enemy = enemy_ref.instance()
	var player_position = player.global_position
	var enemy_position = player_position
	
	while enemy_position.distance_to(player_position) < 250:
		enemy_position = Vector2(rnd.randf_range(0, screen_size.x), rnd.randf_range(0, screen_size.y))
	
	enemy.position = enemy_position
	
	enemy.connect('enemy_killed', self, '_on_enemy_killed', [enemy])
	enemy.connect('player_hit', self, '_on_player_hit')
	
	get_parent().call_deferred('add_child', enemy)


func _on_Player_change_time_changed(time_left):
#	$'../HUD/Timers'.update_change_time(time_left)
#	$'../Control/TimeLabel'.text = time_left
	pass

func _on_enemy_killed(enemy):
	_enemies_killed += 1
	
	randomize()
	var percent = randf()
	
	print(percent)
	
	if (percent > (1 - _powerup_chance)):
		_spawn_powerup(enemy.global_position)
	
	_update_enemies_killed()
	_update_score(enemy.points_when_killed)
	_increase_difficulty()
	
	if _enemies_killed == 1:
		enemy_timer.start()
		spawn_enemy()
		
	yield(get_tree().create_timer(1.2), 'timeout')
	spawn_enemy()

func _on_player_hit():
	_change_state(STATES.GAME_OVER)
	
	
func _spawn_powerup(position):
	print("spawn powerup")
	
	var powerup = powerup_ref.instance()
	powerup.global_position = position
	get_parent().call_deferred('add_child', powerup)
	
func _increase_difficulty():
	enemy_timer.wait_time *= ENEMY_DIFFICULTY_RATIO 

func _decrease_difficulty():
	enemy_timer.wait_time /= ENEMY_DIFFICULTY_RATIO 
	
func _update_enemies_killed():
	$'../HUD/Score'.set_enemies_killed(_enemies_killed)
	
func _update_score(amount):
	_score += amount
	$'../HUD/Score'.set_score(_score)
	
func reset():
	_score = 0
	_enemies_killed = 0
	restart_count += 1
	$'../HUD/Score'.reset()
	player.reset()
	_hide_game_over()
	$'../explanation'.reset()
	player.connect('moved', self, '_on_Player_moved')
	
	var allSpawnedEntities = get_tree().get_nodes_in_group('spawned')
	for entity in allSpawnedEntities:
		entity.queue_free()
		
	enemy_timer.stop()
	
	if restart_count < 5:
		$'../explanation'.show()
		
	yield(get_tree(), 'idle_frame')
	
	enemy_timer.wait_time = DEFAULT_ENEMY_SPAWN_TIME
	
	
func _spawn_enemy_if_needed():
	var enemiesNodes = get_tree().get_nodes_in_group('enemies')
	
	if enemiesNodes.size() == 0:
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
				_hide_paused_overlay()
				_spawn_enemy_if_needed()
		
		STATES.GAME_OVER:
			if _current_state == STATES.PLAY:
				_current_state = new_state
				_set_paused(true)
				_show_game_over()
				
		STATES.PAUSED:
			if _current_state == STATES.PLAY:
				_current_state = new_state
				$SlowDown.play()
				_set_paused(true)
				_show_paused_overlay()
				
		STATES.RESTART:
			_current_state = STATES.PLAY
			reset()
			_set_paused(false)

func _show_game_over():
	$PlayerDie.play()
	$'../HUD/GameOver'.show_gameover(restart_count)

func _hide_game_over():
	$'../HUD/GameOver'.hide()


func _show_paused_overlay():
	$'../HUD/Pause'.set_global_information(_get_global_information())
	$'../HUD/Pause'.show()
	
	
func _hide_paused_overlay():
	$'../HUD/Pause'.hide()
	
	
func _get_global_information():
	var enemy_nodes = get_tree().get_nodes_in_group('enemies')
	
	var text = 'score: %s\n' % _score
	text += 'powerup chance: %s\n' % _powerup_chance
	text += 'enemy spawn rate: %.2f\n' % enemy_timer.wait_time
	text += 'times restarted: %s\n' % restart_count
	text += 'enemies killed: %s\n' % _enemies_killed
	text += 'enemies alive: %s\n' % enemy_nodes.size()
	text += 'enemies total %s\n' % str(_enemies_killed + enemy_nodes.size())
	
	return text

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed('ui_pause'):
			if _current_state == STATES.PAUSED:
				_change_state(STATES.PLAY)
			else:
				_change_state(STATES.PAUSED)
		
		if event.is_action_pressed('ui_restart'):
			print("RESTART PRESSED")
			_change_state(STATES.RESTART)
	
	
	
	
	

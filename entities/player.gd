extends KinematicBody2D

signal debug
signal change_time_changed
signal shooting
signal moved

# TODO expose this when paused
const ACCELERATION = 1000
const MAX_SPEED = 250
const FRICTION = 1500
const MIN_ATTACK_WAIT_TIME = 0.2
const MAX_ATTACK_WAIT_TIME = 0.9

const MIN_CHANGE_TIME = 2
const MAX_CHANGE_TIME = 9

export(String) var weapon_scene_path

var SHOOTING_DIRECTION = Vector2.RIGHT

var velocity = Vector2.ZERO
var weapon

#do we need this?
var weapon_path

var rnd

var changing = false

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	$AttackTimer.connect('timeout', self, '_on_AttackTimer_timeout')
	$ChangeTimer.connect('timeout', self, '_on_ChangeTimer_timeout')
	$UpdateTimer.connect('timeout', self, '_on_UpdateTimer_timeout')
	
	_init_weapon()
	_randomize()
	
	$AttackTimer.start()
	$ChangeTimer.start()
	$UpdateTimer.start()
	
func _init_weapon():
	var weapon_instance = load(weapon_scene_path).instance()
	var weapon_anchor = $WeaponPivot/WeaponSpawnPoint
	weapon_anchor.add_child(weapon_instance)

	weapon = weapon_anchor.get_child(0)

	weapon_path = weapon.get_path()

func _on_AttackTimer_timeout():
	if changing:
		return
		
	attack()
	
	
func _on_ChangeTimer_timeout():
	_randomize()
	
	
func _on_UpdateTimer_timeout():
	$TimeLabel.text = "%.1f" % $ChangeTimer.time_left
#	emit_signal('change_time_changed', $TimeLabel.text)
	
func _randomize():
	changing = true
	
	_set_random_shooting_direction()
	_set_random_attack_time()
	_set_random_change_time()
	$ReloadAudioPlayer.play()
	_debug()
	
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		$AnimationPlayer.play('walk')
		velocity = input_vector * MAX_SPEED
		
		emit_signal('moved')
		
	else:
		$AnimationPlayer.play('idle')
		velocity = Vector2.ZERO
	
	move_and_slide(velocity)


func _set_random_attack_time():
	$AttackTimer.stop()
	$AttackTimer.start(rnd.randf_range(MIN_ATTACK_WAIT_TIME, MAX_ATTACK_WAIT_TIME))

func _set_random_change_time():
	$ChangeTimer.stop()
	$ChangeTimer.start(rnd.randf_range(MIN_CHANGE_TIME, MAX_CHANGE_TIME))


func _set_random_shooting_direction():
	randomize()
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	directions.shuffle()
	
	SHOOTING_DIRECTION = directions.front()

	var tween = $RotationTween
	
	# kill tweens if any
	tween.stop_all()
		
	tween.interpolate_property($WeaponPivot, 'rotation', $WeaponPivot.rotation, SHOOTING_DIRECTION.angle(), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property($EyesSprite, 'position', $EyesSprite.position, _get_eye_position_by_direction(), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_callback(weapon, 0.25, 'set_direction', SHOOTING_DIRECTION)
	
	tween.start()
	
	yield(tween, 'tween_completed')
	
	changing = false

func _get_eye_position_by_direction():
	match SHOOTING_DIRECTION:
		Vector2.UP: 
			return Vector2(0, -5.2)
		Vector2.RIGHT: 
			return Vector2(1.4, -4)
		Vector2.DOWN: 
			return Vector2(0, -1.4)
		Vector2.LEFT: 
			return Vector2(-1.4, -4)

func attack():
	weapon.attack()
	emit_signal('shooting')


func reset():
	position = Vector2(520, 300)
	changing = false
	
	_set_random_shooting_direction()
	_set_random_attack_time()
	_set_random_change_time()
	
	_debug()



func get_information():
	var direction
	
	match SHOOTING_DIRECTION:
		Vector2.UP: 
			direction = 'UP'
		Vector2.RIGHT: 
			direction = 'RIGHT'
		Vector2.DOWN: 
			direction = 'DOWN'
		Vector2.LEFT: 
			direction = 'LEFT'
	
	var text = 'shoot time: %.2f\n' % $AttackTimer.wait_time
	text += 'shoot time left: %.2f\n' % $AttackTimer.time_left
	text += 'change time: %.2f\n' % $ChangeTimer.wait_time
	text += 'change time left: %.2f\n' % $ChangeTimer.time_left
	text += 'direction: %s\n' % direction
	
	return text


func _debug():
	if not OS.is_debug_build():
		return
	
	var debug_text = get_information()	
	
	emit_signal('debug', debug_text)

extends KinematicBody2D

signal debug
signal change_time_changed

# TODO expose this when paused
const ACCELERATION = 1000
const MAX_SPEED = 250
const FRICTION = 1500
const MIN_ATTACK_WAIT_TIME = 0.2
const MAX_ATTACK_WAIT_TIME = 0.4

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
#	weapon.connect("attack_finished", self, "_on_Weapon_attack_finished")


func _on_AttackTimer_timeout():
	if changing:
		return
		
	attack()
	
	
func _on_ChangeTimer_timeout():
	_randomize()
	
	
func _update_shooting_indicator():
#	$WeaponPivot/ShootIndicator.value = ($AttackTimer.wait_time - $AttackTimer.time_left) / $AttackTimer.wait_time * 100
	pass
	
func _on_UpdateTimer_timeout():
	$TimeLabel.text = str(stepify($ChangeTimer.time_left, 0.01))
#	emit_signal('change_time_changed', $ChangeTimer.time_left)
	
func _randomize():
	changing = true
	
	_set_random_shooting_direction()
	_set_random_attack_time()
	_debug()
	
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		$AnimationPlayer.play('walk')
		velocity = input_vector * MAX_SPEED		
		
	else:
		$AnimationPlayer.play('idle')
		velocity = Vector2.ZERO
	
	move_and_slide(velocity)
	_update_shooting_indicator()


func _set_random_attack_time():
	$AttackTimer.wait_time = rnd.randf_range(MIN_ATTACK_WAIT_TIME, MAX_ATTACK_WAIT_TIME)


func _set_random_shooting_direction():
	randomize()
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	directions.shuffle()
	
	SHOOTING_DIRECTION = directions.front()

	var tween = $RotationTween
	
	# kill tweens if any
	tween.stop_all()
		
	tween.interpolate_property($WeaponPivot, 'rotation', $WeaponPivot.rotation, SHOOTING_DIRECTION.angle(), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
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


func reset():
	position = Vector2(640, 400)
	changing = false
	_set_random_shooting_direction()
	_set_random_attack_time()


func _debug():
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

	var debug_text = '$AttackTimer.wait_time: %s\n' % $AttackTimer.wait_time
	debug_text += '$ChangeTimer.wait_time: %s\n' % $ChangeTimer.wait_time
	debug_text += 'SHOOTING_DIRECTION: %s\n' % direction
	
	
	emit_signal('debug', debug_text)

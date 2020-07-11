extends KinematicBody2D

# TODO expose this when paused
const ACCELERATION = 1000
const MAX_SPEED = 180
const FRICTION = 1000
const MIN_ATTACK_WAIT_TIME = 0.5
const MAX_ATTACK_WAIT_TIME = 7

export(String) var weapon_scene_path

var SHOOTING_DIRECTION = Vector2.RIGHT

var velocity = Vector2.ZERO
var weapon

#do we need this?
var weapon_path

var rnd

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	$AttackTimer.connect('timeout', self, '_on_Timer_timeout')
	
	_init_weapon()
	_set_random_shooting_direction()
	_start_timer()

func _init_weapon():
	var weapon_instance = load(weapon_scene_path).instance()
	var weapon_anchor = $WeaponPivot/WeaponSpawnPoint
	weapon_anchor.add_child(weapon_instance)

	weapon = weapon_anchor.get_child(0)

	weapon_path = weapon.get_path()
#	weapon.connect("attack_finished", self, "_on_Weapon_attack_finished")


func _on_Timer_timeout():
	attack()
	
	
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide(velocity)

	$WeaponPivot/WeaponSpawnPoint.look_at(get_global_mouse_position())
	

func _start_timer():
	$AttackTimer.wait_time = rnd.randf_range(MIN_ATTACK_WAIT_TIME, MAX_ATTACK_WAIT_TIME)
	
	$AttackTimer.wait_time = 0.1	
	print("wait time = ", $AttackTimer.wait_time)
	
	$AttackTimer.start()


func _set_random_shooting_direction():
	randomize()
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	directions.shuffle()
	
	SHOOTING_DIRECTION = directions.front()
	
	

func attack():
	weapon.attack()

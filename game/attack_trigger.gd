extends Timer

signal attack

# TODO: make this adjustable by player in PAUSE-SCREEN?
const MIN_ATTACK_TIME = 0.5
const MAX_ATTACK_TIME = 7

var rnd = RandomNumberGenerator.new()

func _ready():
	print('random attack triger')
	
	rnd.randomize()
	
	_set_random_time()
	
	# warning-ignore:return_value_discarded
	connect('timeout', self, '_on_timeout')

func _on_timeout():
	emit_signal('attack')
	

func change_time():
	_set_random_time()
	
func _set_random_time():
	wait_time = rnd.randf_range(MIN_ATTACK_TIME, MAX_ATTACK_TIME)

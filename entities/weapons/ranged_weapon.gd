extends BaseWeapon

var shoot_explosion = preload('res://entities/weapons/shoot_explosion.tscn')

export(PackedScene) var bulletReference

var world

func _ready():
	var nodes = get_tree().get_nodes_in_group('world')
	world = nodes.front()

func attack():
	var bullet = bulletReference.instance()
	bullet.rotation = get_parent().get_parent().rotation
	bullet.position = $BulletSpawnPosition.global_position
	
	var explosion = shoot_explosion.instance()
	explosion.rotation = get_parent().get_parent().rotation
	explosion.position = $BulletSpawnPosition.global_position
	world.add_child(explosion)
	
	$AnimationPlayer.play('shoot')
	
	yield(get_tree(), 'idle_frame')
	world.add_child(bullet)
	
	
func set_direction(direction):
	print("set_direction!!!")
	print(direction)
	
	_get_gun_flip_by_direction(direction)


func _get_gun_flip_by_direction(direction):
	match direction:
		Vector2.UP: 
			$Sprite.flip_h = false
			position.x = 10
		Vector2.RIGHT: 
			$Sprite.flip_h = false
			position.x = 0
		Vector2.DOWN: 
			$Sprite.flip_h = false
			position.x = 10
		Vector2.LEFT: 
			$Sprite.flip_h = true
			position.x = 0

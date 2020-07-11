extends BaseWeapon

export(PackedScene) var bulletReference

var world

func _ready():
	var nodes = get_tree().get_nodes_in_group('world')
	world = nodes.front()

func attack():
	var bullet = bulletReference.instance() as Bullet
	bullet.rotation = get_parent().rotation
	bullet.position = $BulletSpawnPosition.global_position
	world.add_child(bullet)
	

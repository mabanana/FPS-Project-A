extends Node3D
class_name Gun

@export var gun: GunResource
var shoot_cd : int = 200
var mag_curr : int

func _ready():
	mag_curr = gun.mag_size

func set_shoot_cd():
	shoot_cd = 100/gun.fire_rate

func _process(delta):
	if shoot_cd > 0:
		shoot_cd -= 100 * delta
	else:
		shoot_cd = 0

func shoot():
	if shoot_cd == 0 and mag_curr > 0:
		set_shoot_cd()
		mag_curr -= 1
		return true
	else:
		return false

func reload():
	mag_curr = gun.mag_size

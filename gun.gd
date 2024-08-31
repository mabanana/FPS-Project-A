extends Node3D
class_name Gun

@export var mag_size: int
@export var damage_floor: int
@export var damage_ceiling: int
@export var fire_rate: int
var shoot_cd : int = 200


func set_shoot_cd():
	shoot_cd = 100/fire_rate

func _process(delta):
	if shoot_cd > 0:
		shoot_cd -= 100 * delta
	else:
		shoot_cd = 0
	

func shoot():
	if shoot_cd == 0:
		set_shoot_cd()
		return true
	else:
		return false

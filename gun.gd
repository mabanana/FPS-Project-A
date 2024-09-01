extends Node3D
class_name GunSlot

@onready var bullet_hole: PackedScene = preload("res://bullet_hole.tscn")
@export var gun: GunResource
var shoot_cd : int
var reload_cd : int
var reloading: bool
var new_mag: int
const UNIT = 100

func _ready():
	reload_cd = UNIT * gun.reload_time 
	reloading = false
	shoot_cd = 0

func set_shoot_cd():
	shoot_cd = 100/gun.fire_rate

func _process(delta):
	if shoot_cd > 0:
		shoot_cd -= UNIT * delta
	if reloading:
		if reload_cd > 0:
			reload_cd -= UNIT * delta
		else:
			reloading = false
			finish_reload()

func shoot():
	if shoot_cd <= 0 and gun.mag_curr > 0 and not reloading:
		set_shoot_cd()
		gun.mag_curr -= 1
		return true
	else:
		return false

func finish_reload():
	gun.mag_curr = new_mag

func reload(mag):
	new_mag = mag
	reloading = true
	reload_cd = UNIT * gun.reload_time

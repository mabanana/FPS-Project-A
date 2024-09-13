extends RefCounted
class_name Countdown

const UNIT: int = 100

var cd: int
var cd_start_value: int

func _init(cd_start_value: int):
	self.cd_start_value = cd_start_value

func tick(delta: float):
	if cd > 0:
		cd -= UNIT * delta
	return cd
	
func reset_cd():
	cd = cd_start_value

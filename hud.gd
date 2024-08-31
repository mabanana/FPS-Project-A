extends Control
class_name hud_controller

var ammo = 100
var mag = 12
var hp = 100

@onready var ammo_label = %Total
@onready var mag_label = %Magazine
@onready var hp_label = %HpValue

func update():
	ammo_label.text = str(ammo)
	mag_label.text = str(mag)
	hp_label.text = str(hp)

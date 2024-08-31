extends Control
class_name hud_controller

var ammo : int = 100
var mag : int = 12
var hp : int = 100
var reload : bool = false

@onready var ammo_label = %Total
@onready var mag_label = %Magazine
@onready var hp_label = %HpValue
@onready var reload_label = %ReloadIndicator

func update():
	ammo_label.text = str(ammo)
	mag_label.text = str(mag)
	hp_label.text = str(hp)
	reload_label.visible = reload

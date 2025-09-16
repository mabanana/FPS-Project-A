class_name InventoryModel

var gold: int
var guns: Array[GunModel]
var active_gun_index: int
var ammo: int

func _init() -> void:
	guns = []
	
	# Temporary placeholder values
	ammo = 500
	gold = 0

var active_gun: GunModel:
	get:
		if len(guns) == 0:
			return null

		return guns[active_gun_index]

class_name InventoryModel

var guns: Array[GunModel]

func _init() -> void:
	guns = []

var active_gun: GunModel:
	get:
		if len(guns) == 0:
			return null

		return guns[0]

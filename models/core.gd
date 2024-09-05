class_name CoreModel

var inventory: InventoryModel
var map: MapModel

func _init() -> void:
	inventory = InventoryModel.new()
	map = MapModel.new()

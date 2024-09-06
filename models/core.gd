class_name CoreModel

var inventory: InventoryModel
var map: MapModel
var player: PlayerModel

func _init() -> void:
	inventory = InventoryModel.new()
	map = MapModel.new()
	player = PlayerModel.new()

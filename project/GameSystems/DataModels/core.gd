extends Node
class_name CoreModel

var inventory: InventoryModel
var map: MapModel
var player: PlayerModel
var services: CoreServices

var loaded = false

func _ready() -> void:
	inventory = InventoryModel.new()
	map = MapModel.new()
	player = PlayerModel.new()
	services = CoreServices.new()
	loaded = true
	Signals.core_loaded.emit(null)

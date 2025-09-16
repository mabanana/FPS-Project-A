class_name MapModel

var entities: Dictionary[int, EntityModel]
var player_pos: Vector3

func _init() -> void:
	entities = {}
	# { rid : EntityModel }

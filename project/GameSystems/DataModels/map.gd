class_name MapModel

var entities: Dictionary[int, EntityModel]
var player_pos: Vector3
var player_rid: int

func _init() -> void:
	entities = {}
	# { rid : EntityModel }

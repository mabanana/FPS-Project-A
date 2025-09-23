class_name MapModel

var entities: Dictionary[int, EntityModel]
var nodes: Dictionary[int, Node]
var player_pos: Vector3
var player_rid: int

func _init() -> void:
	entities = {}
	# { rid : EntityModel }
